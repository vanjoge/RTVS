#!/usr/bin/env node

process.title = 'mediasoup-demo-server';
process.env.DEBUG = process.env.DEBUG || '*INFO* *WARN* *ERROR*';

const config = require('./config');

/* eslint-disable no-console */
console.log('process.env.DEBUG:', process.env.DEBUG);
console.log('config.js:\n%s', JSON.stringify(config, null, '  '));
/* eslint-enable no-console */

const fs = require('fs');
const http = require('http');
const https = require('https');
const url = require('url');
const protoo = require('protoo-server');
const mediasoup = require('mediasoup');
const express = require('express');
const bodyParser = require('body-parser');
const { AwaitQueue } = require('awaitqueue');
const Logger = require('./lib/Logger');
const Room = require('./lib/Room');
const interactiveServer = require('./lib/interactiveServer');
const interactiveClient = require('./lib/interactiveClient');

const logger = new Logger();

// Async queue to manage rooms.
// @type {AwaitQueue}
const queue = new AwaitQueue();

// Map of Room instances indexed by roomId.
// @type {Map<Number, Room>}
const rooms = new Map();

// HTTP server.
// @type {http.Server}
let httpServer;

// HTTPS server.
// @type {https.Server}
let httpsServer;

// Express application.
// @type {Function}
let expressApp;

// Protoo WebSocket server.
// @type {protoo.WebSocketServer}
let protooWebSocketServer;

// Protoo WebSocket server.
// @type {protoo.WebSocketServer}
let protooWebSocketServer_wss;

// mediasoup Workers.
// @type {Array<mediasoup.Worker>}
const mediasoupWorkers = [];

// Index of next mediasoup Worker to use.
// @type {Number}
let nextMediasoupWorkerIdx = 0;

// rtvs历史流索引
let rtvs_backplay_index = 0;

run();

async function run() {
    // Open the interactive server.
    await interactiveServer();

    // Open the interactive client.
    if (process.env.INTERACTIVE === 'true' || process.env.INTERACTIVE === '1')
        await interactiveClient();

    // Run a mediasoup Worker.
    await runMediasoupWorkers();

    // Create Express app.
    await createExpressApp();

    // Run HTTP server.
    await runHttpServer();

    // Run a protoo WebSocketServer.
    await runProtooWebSocketServer();

    // Log rooms status every X seconds.
    setInterval(() => {
        for (const room of rooms.values()) {
            room.logStatus();
        }
    }, 120000);
}


/**
 * tian_add rtvs请求推流
 */
/*
async function requestRtvsRoom(roomId) {

    logger.info('running runRtvsRoom...');

    const forceH264 = true;
    const forceVP9 = false;
    const room = await getOrCreateRoom({ roomId, forceH264, forceVP9 });

    return await room.createRtvsTransposrt()
}
*/
/**
 * tian_add rtvs停止推流
 */
function stopRtvsRoom(roomId) {
    let room = rooms.get(roomId);
    if (room) {
        room.stopRtvsTransportf(roomId);
    }
}

/**
 * tian_add 发送httpget请求
 */
function httpGetData(rtvsIP, rtvsPort, path, callback) {
    try {
        let query_str = "http://" + rtvsIP + ":" + rtvsPort + path;
        logger.info("http.get url:" + query_str);
        http.get(query_str, function (res) {
            var body = [];
            res.on('data', function (chunk) {
                body.push(chunk);
            });
            res.on('end', function () {
                callback(body.toString());
            });
        }).on('error', (e) => {
            callback('-2');
            logger.error('http.get error:%s', e.message);
        });
    }
    catch (error) {
        callback('-2');
        logger.error('httpGetData failed:%o', error);
    }
}

/**
 * tian_add 发送httppost请求
 */
function httpPostData(path, callback) {

}

/**
 * Launch as many mediasoup Workers as given in the configuration file.
 */
async function runMediasoupWorkers() {
    const { numWorkers } = config.mediasoup;

    logger.info('running %d mediasoup Workers...', numWorkers);

    for (let i = 0; i < numWorkers; ++i) {
        const worker = await mediasoup.createWorker(
            {
                logLevel: config.mediasoup.workerSettings.logLevel,
                logTags: config.mediasoup.workerSettings.logTags,
                rtcMinPort: Number(config.mediasoup.workerSettings.rtcMinPort),
                rtcMaxPort: Number(config.mediasoup.workerSettings.rtcMaxPort)
            });

        worker.on('died', () => {
            logger.error(
                'mediasoup Worker died, exiting  in 2 seconds... [pid:%d]', worker.pid);

            setTimeout(() => process.exit(1), 2000);
        });

        mediasoupWorkers.push(worker);

        // Log worker resource usage every X seconds.
        setInterval(async () => {
            const usage = await worker.getResourceUsage();

            logger.info('mediasoup Worker resource usage [pid:%d]: %o', worker.pid, usage);
        }, 120000);
    }
}

/**
 * Create an Express based API server to manage Broadcaster requests.
 */
async function createExpressApp() {
    logger.info('creating Express app...');

    expressApp = express();

    expressApp.use(bodyParser.json());

	/**
	 * For every API request, verify that the roomId in the path matches and
	 * existing room.
	 */
    expressApp.param(
        'roomId', (req, res, next, roomId) => {
            // The room must exist for all API requests.
            if (!rooms.has(roomId)) {
                const error = new Error(`room with id "${roomId}" not found`);

                error.status = 404;
                throw error;
            }

            req.room = rooms.get(roomId);

            next();
        });

	/**
	 * API GET resource that returns the mediasoup Router RTP capabilities of
	 * the room.
	 */
    expressApp.get(
        '/rooms/:roomId', (req, res) => {
            const data = req.room.getRouterRtpCapabilities();

            res.status(200).json(data);
        });

    return;
	/*
    expressApp.get(
        '/rooms/:roomId/ffmpegtest', (req, res) => {
        const data = req.room.getFfmpegCmd();

        res.status(200).json(data);
    });

    expressApp.get(
        '/rtvs/requeststream', async (req, res) => {
            logger.info("------------------------------");
            logger.info("url:%s", req.url);
            logger.info("baseurl:%s", req.baseUrl);
            logger.info("sim:%s", req.query.sim);
            logger.info("channel:%s", req.query.channel);
            logger.info("describe:%s", req.query.describe);
            logger.info("------------------------------");

            let roomId = req.query.sim + '-' + req.query.channel;
            if (req.query.describe === 'realplay') {
                roomId += '-real'
            } else {
                roomId += '-back' + rtvs_backplay_index++;
            }

            const { isready, videortpport, videortcpport, audiortpport, audiortcpport } = await requestRtvsRoom(roomId);

            if (isready) {
                res.status(200).json(roomId);
                return;
            }

            //通知rtvs服务
            let path = "/webrtc/realplaystart?sim=" + req.query.sim +
                "&channel=" + req.query.channel +
                "&describe=" + req.query.describe +
                "&vrtpport=" + videortpport +
                "&vrtcpport=" + videortcpport +
                "&artpport=" + audiortpport +
                "&artcpport=" + audiortcpport;

            httpGetData(path, function (data) {
                if (data === "1") {
					let str_ret = roomId + "  videortpport:" + videortpport + "  videortcpport:" + videortcpport; 
                    res.status(200).json(str_ret);
                }
                else {
                    res.status(200).json('-1');
                }
            });
    });

    expressApp.get(
        '/rtvs/stopstream', (req, res) => {
            logger.info("------------------------------");
            logger.info("url:%s", req.url);
            logger.info("baseurl:%s", req.baseUrl);
            logger.info("roomId:%s", req.query.roomId);
            logger.info("------------------------------");

            let roomId = req.query.roomId;
            stopRtvsRoom(roomId);

        });

*/

	/**
	 * POST API to create a Broadcaster.
	 */
    expressApp.post(
        '/rooms/:roomId/broadcasters', async (req, res, next) => {
            const {
                id,
                displayName,
                device,
                rtpCapabilities
            } = req.body;

            try {
                const data = await req.room.createBroadcaster(
                    {
                        id,
                        displayName,
                        device,
                        rtpCapabilities
                    });

                res.status(200).json(data);
            }
            catch (error) {
                next(error);
            }
        });

	/**
	 * DELETE API to delete a Broadcaster.
	 */
    expressApp.delete(
        '/rooms/:roomId/broadcasters/:broadcasterId', (req, res) => {
            const { broadcasterId } = req.params;

            req.room.deleteBroadcaster({ broadcasterId });

            res.status(200).send('broadcaster deleted');
        });

	/**
	 * POST API to create a mediasoup Transport associated to a Broadcaster.
	 * It can be a PlainTransport or a WebRtcTransport depending on the
	 * type parameters in the body. There are also additional parameters for
	 * PlainTransport.
	 */
    expressApp.post(
        '/rooms/:roomId/broadcasters/:broadcasterId/transports',
        async (req, res, next) => {
            const { broadcasterId } = req.params;
            const { type, rtcpMux, comedia } = req.body;

            try {
                const data = await req.room.createBroadcasterTransport(
                    {
                        broadcasterId,
                        type,
                        rtcpMux,
                        comedia
                    });

                res.status(200).json(data);
            }
            catch (error) {
                next(error);
            }
        });

	/**
	 * POST API to connect a Transport belonging to a Broadcaster. Not needed
	 * for PlainTransport if it was created with comedia option set to true.
	 */
    expressApp.post(
        '/rooms/:roomId/broadcasters/:broadcasterId/transports/:transportId/connect',
        async (req, res, next) => {
            const { broadcasterId, transportId } = req.params;
            const { dtlsParameters } = req.body;

            try {
                const data = await req.room.connectBroadcasterTransport(
                    {
                        broadcasterId,
                        transportId,
                        dtlsParameters
                    });

                res.status(200).json(data);
            }
            catch (error) {
                next(error);
            }
        });

	/**
	 * POST API to create a mediasoup Producer associated to a Broadcaster.
	 * The exact Transport in which the Producer must be created is signaled in
	 * the URL path. Body parameters include kind and rtpParameters of the
	 * Producer.
	 */
    expressApp.post(
        '/rooms/:roomId/broadcasters/:broadcasterId/transports/:transportId/producers',
        async (req, res, next) => {
            const { broadcasterId, transportId } = req.params;
            const { kind, rtpParameters } = req.body;

            try {
                const data = await req.room.createBroadcasterProducer(
                    {
                        broadcasterId,
                        transportId,
                        kind,
                        rtpParameters
                    });

                res.status(200).json(data);
            }
            catch (error) {
                next(error);
            }
        });

	/**
	 * POST API to create a mediasoup Consumer associated to a Broadcaster.
	 * The exact Transport in which the Consumer must be created is signaled in
	 * the URL path. Query parameters must include the desired producerId to
	 * consume.
	 */
    expressApp.post(
        '/rooms/:roomId/broadcasters/:broadcasterId/transports/:transportId/consume',
        async (req, res, next) => {
            const { broadcasterId, transportId } = req.params;
            const { producerId } = req.query;

            try {
                const data = await req.room.createBroadcasterConsumer(
                    {
                        broadcasterId,
                        transportId,
                        producerId
                    });

                res.status(200).json(data);
            }
            catch (error) {
                next(error);
            }
        });

	/**
	 * Error handler.
	 */
    expressApp.use(
        (error, req, res, next) => {
            if (error) {
                logger.warn('Express app %s', String(error));

                error.status = error.status || (error.name === 'TypeError' ? 400 : 500);

                res.statusMessage = error.message;
                res.status(error.status).send(String(error));
            }
            else {
                next();
            }
        });
}

/**
 * Create a Node.js HTTP server. It listens in the IP and port given in the
 * configuration file and reuses the Express application as request listener.
 */
async function runHttpServer() {
    console.log('running an HTTP server...', process.env.DEBUG);


    httpServer = http.createServer(expressApp);

    await new Promise((resolve) => {
        httpServer.listen(
            Number(config.http.listenPort), config.http.listenIp, resolve);
    });

    if (fs.existsSync(config.https.tls.cert) && fs.existsSync(config.https.tls.key)) {
        console.log('running an HTTPS server...', process.env.DEBUG);

        // HTTP server for the protoo WebSocket server.
        const tls =
        {
            cert: fs.readFileSync(config.https.tls.cert),
            key: fs.readFileSync(config.https.tls.key)
        };

        httpsServer = https.createServer(tls, expressApp);

        await new Promise((resolve) => {
            httpsServer.listen(
                Number(config.https.listenPort), config.https.listenIp, resolve);
        });
    }
}

/**
 * Create a protoo WebSocketServer to allow WebSocket connections from browsers.
 */
async function runProtooWebSocketServer() {
    logger.info('running protoo WebSocketServer...');

    // Create the protoo WebSocket server.
    protooWebSocketServer = new protoo.WebSocketServer(httpServer,
        {
            maxReceivedFrameSize: 960000, // 960 KBytes.
            maxReceivedMessageSize: 960000,
            fragmentOutgoingMessages: true,
            fragmentationThreshold: 960000
        });

    // Handle connections from clients.
    protooWebSocketServer.on('connectionrequest', on_connectionrequest);

    if (httpsServer != null) {
        // Create the protoo WebSocket server.
        protooWebSocketServer_wss = new protoo.WebSocketServer(httpsServer,
            {
                maxReceivedFrameSize: 960000, // 960 KBytes.
                maxReceivedMessageSize: 960000,
                fragmentOutgoingMessages: true,
                fragmentationThreshold: 960000
            });

        // Handle connections from clients.
        protooWebSocketServer_wss.on('connectionrequest', on_connectionrequest);
    }
}

function on_connectionrequest(info, accept, reject) {
    // The client indicates the roomId and peerId in the URL query.
    const u = url.parse(info.request.url, true);
    const sim = u.query['sim'];
    const channel = u.query['channel'];
    const peerId = u.query['peerId'];
    const rtvsIP = u.query['rtvsIP'];
    const rtvsPort = u.query['rtvsPort'];
    const streamType = u.query['streamType'];
    const isReal = u.query['isReal'];
    let guid = "undefined";
    let startTime = "";
    let endTime = "";
    let describe = "";
    if (isReal == 0) {
        startTime = u.query['startTime'];
        endTime = u.query['endTime'];
        guid = u.query['guid'];
        describe = 'history';
        if (!startTime || !endTime) {
            reject(400, 'Connection request without startTime or endTime');
            return;
        }
    }
    else {
        describe = 'realplay';
    }

    if (!sim || !channel || !peerId || !rtvsIP || !rtvsPort) {
        reject(400, 'Connection request without sim and/or channel peerId rtvsIP rtvsPort');

        return;
    }

    logger.info(
        'protoo connection request [sim:%s, channel:%s, describe:%s peerId:%s, address:%s, origin:%s]',
        sim, channel, describe, peerId, info.socket.remoteAddress, info.origin);

    // Serialize this code into the queue to avoid that two peers connecting at
    // the same time with the same roomId create two separate rooms with same
    // roomId.
    queue.push(async () => {
        const room = await getOrCreateRoom({ sim, channel, describe, startTime, endTime, guid, rtvsIP, rtvsPort, streamType, socket: info.socket });
        if (room === undefined) {
            return;
        }
        // Accept the protoo WebSocket connection.
        const protooWebSocketTransport = accept();

        room.handleProtooConnection({ peerId, protooWebSocketTransport });
    })
        .catch((error) => {
            logger.error('room creation or room joining failed:%o', error);

            reject(error);
        });
}



/**
 * Get next mediasoup Worker.
 */
function getMediasoupWorker() {
    const worker = mediasoupWorkers[nextMediasoupWorkerIdx];

    if (++nextMediasoupWorkerIdx === mediasoupWorkers.length)
        nextMediasoupWorkerIdx = 0;

    return worker;
}

/**
 * Get a Room instance (or create one if it does not exist).
 * if not exist request stream from rtvs, if suc craete room else not 
 */
async function getOrCreateRoom({ sim, channel, describe, startTime, endTime, guid, rtvsIP, rtvsPort, streamType, socket }) {
    let roomId = "";
    if (guid == "undefined") {
        roomId = sim + '-' + channel + '-' + describe;
    } else {
        roomId = guid;
    }
    let room = rooms.get(roomId);

    // If the Room does not exist create a new one.
    if (!room) {
        logger.info('creating a new Room [roomId:%s]', roomId);

        const mediasoupWorker = getMediasoupWorker();

        room = await Room.create({ mediasoupWorker, roomId, rtvsIP, rtvsPort });

        //创建上传
        const { videortpport, videortcpport, audiortpport, audiortcpport } = await room.createRtvsTransport()

        let path = "";
        //通知rtvs服务
        if (guid != "undefined") {
            path = "/webrtc/videoplaystart?sim=" + sim +
                "&channel=" + channel +
                "&describe=" + describe +
                "&starttime=" + startTime +
                "&endtime=" + endTime +
                "&describe=" + describe +
                "&stream_type=" + streamType +
                "&vrtpport=" + videortpport +
                "&vrtcpport=" + videortcpport +
                "&artpport=" + audiortpport +
                "&artcpport=" + audiortcpport +
                "&roomid=" + roomId +
                "&IP=" + socket.remoteAddress +
                "&Port=" + socket.remotePort;

            ;
        } else {
            path = "/webrtc/videoplaystart?sim=" + sim +
                "&channel=" + channel +
                "&describe=" + describe +
                "&stream_type=" + streamType +
                "&vrtpport=" + videortpport +
                "&vrtcpport=" + videortcpport +
                "&artpport=" + audiortpport +
                "&artcpport=" + audiortcpport +
                "&roomid=" + roomId +
                "&IP=" + socket.remoteAddress +
                "&Port=" + socket.remotePort;
        }

        logger.info('getOrCreateRoom request rtvs [url:%s]', path);

        await new Promise(function (resolve, reject) {
            httpGetData(rtvsIP, rtvsPort, path, function (data) {
                if (data === "1") {
                    let str_ret = "rtvs ret success " + roomId + "  videortpport:" + videortpport + "  videortcpport:" + videortcpport;
                    logger.info(str_ret);
                    resolve(1);
                }
                else {
                    if (data == "0") {
                        logger.info("rtvs ret 0 cheji not online rtvsIP：" + rtvsIP + " rtvsPort:" + rtvsPort);
                    }
                    else
                        logger.info("rtvs ret failed rtvsIP：" + rtvsIP + " rtvsPort:" + rtvsPort);
                    reject(0);
                }
            });
        }).then(function (value) {
            rooms.set(roomId, room);
            room.on('close', function () {
                rooms.delete(roomId);
                let req = "/webrtc/videoplaystop?sim=" + sim +
                    "&channel=" + channel +
                    "&roomid=" + roomId;
                httpGetData(rtvsIP, rtvsPort, req, () => { });
            });
        })
            .catch(function (value) {
                room = undefined;
            });
    }

    return room;
}
