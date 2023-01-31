/**
 * IMPORTANT (PLEASE READ THIS):
 *
 * This is not the "configuration file" of mediasoup. This is the configuration
 * file of the mediasoup-demo app. mediasoup itself is a server-side library, it
 * does not read any "configuration file". Instead it exposes an API. This demo
 * application just reads settings from this file (once copied to config.js) and
 * calls the mediasoup API with those settings when appropriate.
 */

const os = require('os');

module.exports =
{
    // Listening hostname (just for `gulp live` task).
    domain: process.env.DOMAIN || 'localhost',
    // Signaling settings (protoo WebSocket server and HTTP API server).
	httpApi:
    {
        listenIp: '0.0.0.0',
        listenPort: process.env.PROTOO_LISTEN_PORT_HTTP_API || 13188
    },
    http:
    {
        listenIp: '0.0.0.0',
        // NOTE: Don't change listenPort (client app assumes 4080).
        listenPort: process.env.PROTOO_LISTEN_PORT_HTTP || 9.9.9.9
    },
    // Signaling settings (protoo WebSocket server and HTTPS API server).
    https:
    {
        listenIp: '0.0.0.0',
        // NOTE: Don't change listenPort (client app assumes 4443).
        listenPort: process.env.PROTOO_LISTEN_PORT || 9.9.9.10,
        // NOTE: Set your own valid certificate files.
        tls:
        {
            cert: process.env.HTTPS_CERT_FULLCHAIN || `${__dirname}/certs/server.crt`,
            key: process.env.HTTPS_CERT_PRIVKEY || `${__dirname}/certs/server.key`
        }
    },
    // mediasoup settings.
    mediasoup:
    {
        // Number of mediasoup workers to launch.
        numWorkers: Object.keys(os.cpus()).length,
        // mediasoup WorkerSettings.
        // See https://mediasoup.org/documentation/v3/mediasoup/api/#WorkerSettings
        workerSettings:
        {
            logLevel: 'debug',
            logTags:
                [
                    'info',
                    'ice',
                    'dtls',
                    'rtp',
                    'srtp',
                    'rtcp',
                    'rtx',
                    'bwe',
                    'score',
                    'simulcast',
                    'svc',
                    'sctp'
                ],
            rtcMinPort: process.env.MEDIASOUP_MIN_PORT || 1.1.1.1,
            rtcMaxPort: process.env.MEDIASOUP_MAX_PORT || 2.2.2.2
        },
        // mediasoup Router options.
        // See https://mediasoup.org/documentation/v3/mediasoup/api/#RouterOptions
        routerOptions:
        {
            mediaCodecs:
                [
                    {
                        kind: 'audio',
                        mimeType: 'audio/PCMA',
                        preferredPayloadType: 8,
                        clockRate: 8000,
                        rtcpFeedback:
                            [
                                { type: 'transport-cc' }
                            ]
                    },
                    {
                        kind: 'audio',
                        mimeType: 'audio/PCMU',
                        preferredPayloadType: 0,
                        clockRate: 8000,
                        rtcpFeedback:
                            [
                                { type: 'transport-cc' }
                            ]
                    },
                    {
                        kind: 'audio',
                        mimeType: 'audio/opus',
                        clockRate: 48000,
                        channels: 2
                    },
                    {
                        kind: 'video',
                        mimeType: 'video/h264',
                        clockRate: 90000,
                        parameters:
                        {
                            'packetization-mode': 1,
                            'profile-level-id': '42e01f',
                            'level-asymmetry-allowed': 1
                        },
                        rtcpFeedback:
                            [
                                { type: 'nack' },
                                { type: 'nack', parameter: 'pli' },
                                { type: 'ccm', parameter: 'fir' },
                                { type: 'goog-remb' },
                                { type: 'transport-cc' }
                            ]
                    },
                    {
                        kind: 'video',
                        mimeType: 'video/h264',
                        clockRate: 90000,
                        parameters:
                        {
                            'packetization-mode': 0,
                            'level-asymmetry-allowed': 1
                        },
                        rtcpFeedback:
                            [
                                { type: 'nack' },
                                { type: 'nack', parameter: 'pli' },
                                { type: 'ccm', parameter: 'fir' },
                                { type: 'goog-remb' },
                                { type: 'transport-cc' }
                            ]
                    }
                ]
        },
        // mediasoup WebRtcTransport options for WebRTC endpoints (mediasoup-client,
        // libmediasoupclient).
        // See https://mediasoup.org/documentation/v3/mediasoup/api/#WebRtcTransportOptions
        webRtcTransportOptions:
        {
            listenIps:
                [
                    {
                        ip: process.env.MEDIASOUP_LISTEN_IP || '0.0.0.0',
                        announcedIp: process.env.MEDIASOUP_ANNOUNCED_IP || '1.2.3.4'
                    }
                ],
            initialAvailableOutgoingBitrate: 1000000,
            minimumAvailableOutgoingBitrate: 600000,
            maxSctpMessageSize: 262144,
            // Additional options that are not part of WebRtcTransportOptions.
            maxIncomingBitrate: 1500000
        },
        // mediasoup PlainTransport options for legacy RTP endpoints (FFmpeg,
        // GStreamer).
        // See https://mediasoup.org/documentation/v3/mediasoup/api/#PlainTransportOptions
        plainTransportOptions:
        {
            listenIp:
            {
                ip: process.env.MEDIASOUP_LISTEN_IP || '0.0.0.0',
                announcedIp: process.env.MEDIASOUP_ANNOUNCED_IP || '1.2.3.4'
            },
            maxSctpMessageSize: 262144
        }
    },
    cvconf: {
        onlyTcp: process.env.cvconf_onlyTcp || false,
        onlyUdp: process.env.cvconf_onlyUdp || false,
        dcHost: process.env.cvconf_dcHost || false
    }
};
