   * [JS视频播放插件](#JS视频播放插件)
      * [环境说明](#环境说明)
      * [API说明](#API说明)
         * [初始化和分屏](#初始化和分屏)
            * [初始化控件](#初始化控件)
            * [自定义分屏](#自定义分屏)
            * [设置分屏数量](#设置分屏数量)
         * [播放和控制](#播放和控制)
            * [发起实时视频](#发起实时视频)
            * [实时视频传输控制](#实时视频传输控制)
            * [发起历史视频请求](#发起历史视频请求)
            * [发起历史视频控制](#发起历史视频控制)
            * [请求服务器视频文件列表](#请求服务器视频文件列表)
            * [开始对讲](#开始对讲)
            * [结束对讲](#结束对讲)
            * [发送FTP视频上传指令](#发送ftp视频上传指令)
            * [发送FTP视频上传控制指令](#发送ftp视频上传控制指令)
            * [关闭或关闭所有视频](#关闭或关闭所有视频)
            * [发送云台旋转控制指令](#发送云台旋转控制指令)
            * [发送云台调整焦距控制指令](#发送云台调整焦距控制指令)
            * [发送云台调整光圈控制指令](#发送云台调整光圈控制指令)
            * [发送云台雨刷控制指令](#发送云台雨刷控制指令)
            * [发送云台红外补光控制指令](#发送云台红外补光控制指令)
            * [发送云台变倍控制指令](#发送云台变倍控制指令)
            * [获取历史流播放缓存](#获取历史流播放缓存)
            * [Gov播放](#Gov播放)
            * [下载历史视频文件](#下载历史视频文件)
            * [下载FMP4文件](#下载FMP4文件)
         * [其他](#其他)
            * [截图](#截图)
            * [刷新](#刷新)
            * [暂停](#暂停)
            * [恢复播放](#恢复播放)
            * [获取音量](#获取音量)
            * [设置音量](#设置音量)
            * [全屏](#全屏)
            * [开始录像](#开始录像)
            * [停止录像](#停止录像)
            * [设置视频宽高比](#设置视频宽高比)
            * [设置播放速度](#设置播放速度)
            * [视频旋转](#视频旋转)
            * [视频镜面反转](#视频镜面反转)
            * [整体全屏](#整体全屏)
            * [重新设置大小](#重新设置大小)
            * [视频镜面反转](#视频镜面反转-1)
            * [osd显示开关](#osd显示开关)
            * [osd文本颜色](#osd文本颜色)
            * [osd文本](#osd文本)
            * [是否播放](#是否播放)
            * [设置超时时间](#设置超时时间)
            * [设置优先级](#设置优先级)
         * [属性](#属性)
            * [Videos](#Videos)
      * [功能测试页面](#功能测试页面)

JS视频播放插件
===
环境说明
----
引用
```
 <script type="text/javascript" src="http://lib.cvtsp.com/video/CVNetVideoJs/1.3.0/CvNetVideo.js"></script>

```
## API说明


### 初始化和分屏
#### 初始化控件
----
   接口 返回UCMain对象，与静态方法具有同名接口。用以支持一个页面初始化多个视频控件。
```
Init(dom, VideoNums = 4, config = {});

```
   参数说明
```
dom:视频控件插入节点，一般是div
VideoNums:显示视频控件数量，后期可调整，支持1, 2, 4, 6, 9, 10, 16
config:配置项
defaultConfig = {
                //以下只可初始化传入 后期不可改
                //与dom参数一致 
                media: null,
                //初始化分屏数量 此处可调整分屏最大数量 建议够用就行 设过大可能影响页面性能
                MaxUcNum: 16,
                //视频显示宽度
                videoWidth: 352,
                //视频显示高度
                videoHeight: 288,
                //wasm库加载地址
                libffmpegUrl: "/Scripts/libffmpeg.js",
                //css地址 如需修改控件样式，请自行指定css地址
                cssUrl: "/css/CVNetVideo.css",
                recordVideo: true,
                screenshot: true,
                yuntaiCtrl: true,
                networkSpeaking: true,
                //超时警告时间 默认4.5分钟通知
                timeoutWarningMsec: 270000,
                //超时时间 默认5分钟
                timeoutCloseMsec: 300000,
                //事件通知
                events: {
                    //超时警告通知 仅通知
                    //参数1 leftMsec 剩余关闭毫秒
                    //参数2 time 上次有动作时间
                    timeoutWarning: null,
                    //超时警告取消 表示警告通知后用户有了操作 重新开始计时
                    timeoutCanceled: null,
                    //超时通知 仅通知，如需关闭需用户在此事件响应中自行调用关闭接口
                    //参数 time 上次有动作时间
                    timeoutClose: null,
                    //截图时事件
                    //参数1 base64png base64编码的png图片
                    //参数2 id 表示第几个分屏 从1开始 -1表示对讲通道
                    //参数3 UCVideo对象
                    //返回值表示是否取消默认后续下载操作，为真时表示取消
                    onCapture: null,
                    //停止视频时事件
                    //参数1 id 表示第几个分屏 从1开始 -1表示对讲通道
                    //参数2 停止的UCVideo对象
                    onStop: null,
                    //设备开始传输视频事件
                    //参数1 id 表示第几个分屏 从1开始 -1表示对讲通道
                    //参数2 UCVideo对象
                    onDevConnect: null,
                    //设备断开传输视频事件
                    //参数1 id 表示第几个分屏 从1开始 -1表示对讲通道
                    //参数2 UCVideo对象
                    onDevDisconnect: null,
                    //Websocket通道关闭事件
                    //参数1 id 表示第几个分屏 从1开始 -1表示对讲通道
                    //参数2 UCVideo对象
                    onWsClose: null,
                    //服务端通知事件
                    //参数1 事件类型 字符串(onDevConnect onDevDisconnect onWsClose)之一
                    //参数2 id 表示第几个分屏 从1开始 -1表示对讲通道
                    //参数3 UCVideo对象
                    onServerNotice: null,
                    //服务端结束
                    //参数1 结束原因 字符串
                    //参数2 id 表示第几个分屏 从1开始 -1表示对讲通道
                    //参数3 UCVideo对象
                    //返回值表示是否取消自动停止，为真时表示取消
                    onEndByServer: null,
                    //hls模式获取到HLS地址时触发
                    //参数1 id 表示第几个分屏 从1开始
                    //参数2 UCVideo对象
                    //参数3 hls_http地址
                    //参数4 hls_https地址
                    //参数5 rtmp地址
                    //参数6 clinetID 客户端ID 每次请求会不一样
                    //返回值表示是否取消自动播放，为真时表示取消
                    onHlsPlay: null,
                    //对讲开始 与设备链路建立完成，且可开始对讲时触发
                    //参数 无
                    onStartSpeek: null,
                    //客户端获取麦克风错误，一般多见于无麦克风强行开启对讲的场景
                    //参数 Error
                    onMicError: null,
                    //时间戳播放回调
                    //参数1 id 表示第几个分屏 从1开始
                    //参数2 timestamp 时间戳
                    onTimeStamp:null,
                    //分屏双击回调，
                    //参数1 id 表示第几个分屏 从1开始
                    //参数2 UCVideo对象
                    //返回值 true表示取消双击放大
                    onUcDbclick: null,
                    //流量统计回调，
                    //参数1 KBps 数值，建议toFixed(2)后再显示
                    //参数2 id 表示第几个分屏 从1开始
                    //参数3 UCVideo对象
                    onKBpsChange: null,
                    //本地录像完成回调，
                    //参数1 录像Blob
                    //参数2 录像信息 { type, sim, channel, startTime, stopTime}
                    //参数3 id 表示第几个分屏 从1开始
                    //参数4 UCVideo对象
                    //返回值 true表示取消自动下载
                    onEndRecord: null,
                    //回放缓存时间回调
                    //参数1 {playedMs,waitingPlayMs} playedMs:已播放时长(毫秒) waitingPlayMs:已缓冲未播放时长(毫秒)
                    //参数2 id 表示第几个分屏 从1开始
                    //参数3 UCVideo对象
                    onPlayBackCacheTime: null,
                },
                //初始化完成通知
                callback: null,
                //gov授权码，未授权版本仅允许播放一路视频，且30秒自动断开。
                govmd5: "",
                govnum: 100,
                //开始传输以后，gov多少毫秒未收到数据关闭URL
                govTimeoutMsec: 5000,


                //以下参数可调用方法时修改

                //token类型 0:不启用 1:一次有效随机码，需先通过后端接口申请 2:RSA加密当前时间戳
                tokenType: 0,
                //token
                token: null,
                //选中时取消分屏静音
                unmuteBySelected: true,
                //选中分屏zindex
                selectedZIndex: 999,
                //启用双击放大单窗口
                enableDbcZoom: true,
                //0 自动 1 WASM软解(canvas+audioAPI) 2 js封装FMP4(h264Demuxer+audioAPI) 3 WASM封装FMP4(WASM2FMP4) 4 服务器推fmp4流 5 webrtc 6 hls 7 webrtc(srs)
                //模式1 2 3已经停止更新，新版本可能存在不兼容情况，不推荐使用
                playerMode: 0,
                //是否使用集群管理分配服务器信息
                usingCluster: true,
                //集群管理地址
                clusterHost: "127.0.0.1",
                //集群管理端口
                clusterPort: 17000,
                //服务器地址(集群版本之后不需设置，会自动从集群管理获取)
                remoteHost: "127.0.0.1",
                //服务器Ws端口 默认18002(集群版本之后不需设置，会自动从集群管理获取)
                remotePortWs: 18002,
                //服务器FMP4端口 默认18003(集群版本之后不需设置，会自动从集群管理获取)
                remotePortFmp4: 18003,
                //优先级
                priority: 0,
                //h264Demuxer 模式2时有效 按关键帧打pts
                forceKeyFrameOnDiscontinuity: true,
                //PCM播放缓冲时间(秒)
                pcmCacheSec: 0.2,
                //
                maxPcmQueueCount: 15,
                //0 不延迟 其他按时间戳延迟
                speekSendMode: 0,
                //播放过程中是否显示正在加载loading框
                showLoadingByPlay: true,
                //显示loading延迟毫秒
                showLoadDelayMs: 1000,
                //追帧模式 小于0 不追帧 0 跳到最新 其他 倍速加速
                seekMode: 1,
                //最大允许延迟秒 超过则开始追帧
                maxDelay: 8,
                //选中事件
                selectedEvent: null,
                //截图图片类型 0 png, 1 jpeg, 2 webp
                captureType: 0,
                //截图图片质量 0-1 jpeg和webp时有效
                captureQuality: null,
                //流畅模式，开播会缓存够一定时间buff，保证播放流畅性，但延迟稍高 fmp4模式有效
                smoothMode: false,
                //协议版本 0 808-2013 1 808-2019 2 GB28181
                protocol: 0,
                //默认ctags
                defaultCtags: null,
                //录像起播缓存(ms)
                playbackStartCache: 2000,
                //多语言配置
                language: {
                    timeout: "超时",
                    connect_failed:"连接失败",
                    connect_error: "连接错误",
                    connect_close: "连接关闭",
                    connect_down: "传输完成",
                    device_connected: "设备连接",
                    device_disconnect: "设备断开",
                    gov_player_http_request_failed: "URL请求失败",
                    gov_player_http_request_error: "URL请求发生错误",
                    gov_player_limited_connection: "超过允许最大连接数，断开连接",
                    gov_player_limited_play_time: "超过允许播放时长，断开连接",
                    gov_player_protocol_error: "协议错误，请确认流格式是否正确",
                    loading_page_wait_video: "等待视频...",
                    loading_page_wait_search_record: "等待搜索录像",
                    menu_stop: "停止",
                    menu_screen_full: "全屏",
                    menu_stretch: "伸缩",
                    menu_capture: "截图",
                    menu_rotate: "视频旋转",
                    menu_mirrorinver: "镜面反转",
                    control_tip_refresh: "刷新",
                    control_tip_play: "播放",
                    control_tip_stop: "停止",
                    control_tip_sound: "声音",
                    control_tip_screen_full: "全屏",
                    control_tip_capture: "截图",
                    control_tip_record: "录像",
                    control_tip_stretch: "伸缩",
                },
                //添加菜单
                //addMenu:[
                //    {
                //        title: "测试1", child:
                //        [
                //                { title: "111", onClicked: function (index) { console.log("clicked 111-" + index) } },
                //                { title: "222", onClicked: function (index) { console.log("clicked 222-" + index) } },
                //                { title: "333", onClicked: function (index) { console.log("clicked 333-" + index) } }
                //        ]
                //    },
                //    {
                //        title: "测试2", onClicked: function (index) { console.log("clicked 测试2-" + index) }
                //    },
                //    {
                //        title: "测试3", child:
                //        [
                //                { title: "555", onClicked: function (index) { console.log("clicked 555-" + index) } },
                //        ]
                //    },
                //],
                
                //添加按钮 需在class中指定按钮图标和位置
                /*addButtons:[
                    { title: "add1", class: "addbuton-1", onClicked: function (index) { console.log("addbuton-1-" + index) } },
                    { title: "add1", class: "addbuton-2", onClicked: function (index) { console.log("addbuton-2-" + index) } },
                ],*/
                //是否使用cdn
                isUseCdn: false,
            };
```
   示例

```
window.onload = function () {
            console.log(CvNetVideo.version);
            //this.setTimeout(init, 2000);
            init();

        };
        var uc1;
        function init() {
            uc1 = CvNetVideo.Init(document.querySelector("#player"), 4,
                {
                    remoteHost: "127.0.0.1",
                    playerMode: 4,
                    callback: function () {
                        [].forEach.call(document.querySelectorAll("button"), function (btn) {
                            btn.disabled = false;
                        });
                    }
                });
       }
```

#### 自定义分屏
     接口
```
CustomScreens(screenIndex, callback);
```
   参数说明
```
screenIndex:分屏key，与CvNetVideo.LayoutByScreens参数对应。
不要为数值，否则可能与默认分屏冲突。

callback:分屏计算回调
```
     示例
```
   uc1.CustomScreens("3X2", function(width, height) {
            width = parseInt((width - 4) / 3);
            height = parseInt((height - 4) / 2);
            uc1.VideosforEach(function (video, i) {
                var video_div = video.GetVideoDiv();
                if (i > 6) {
                    //超过分屏数量隐藏掉
                    video_div.style.display = "none";
                } else {
                    //计算当前分屏所在位置
                    video_div.style.display = "block";
                    let index = i - 1;
                    let left = 2 + (index % 3) * width;
                    let top = 2 + parseInt(index / 3) * height;
                    video_div.style.left = left + "px";
                    video_div.style.top = top + "px";
                    video_div.style.width = (width - 4) + "px";
                    video_div.style.height = (height - 4) + "px";
                    video.Resize();
                }
            });
        });
   uc1.LayoutByScreens("3X2");
```

#### 设置分屏数量

     接口
```
 LayoutByScreens(num); 

```
   参数说明
```
num:默认支持1, 2, 4, 6, 8, 9, 10, 13, 16 如果无效默认选择4分屏,可结合CustomScreens自定义分屏
```
      示例
```
 CvNetVideo.LayoutByScreens(4);

```


### 播放和控制
#### 发起实时视频

     接口
```
StartRealTimeVideo(Sim, Channel, streamType = 1, hasAudio = true, videoId = 0, config = {}, Callback = null, playermode = 0);
```
   参数说明
```
Sim:sim卡号
Channel:通道号不支持0
streamType:主子码流 0 主码流 1 子码流
hasAudio:是否打开音频
videoId:窗口ID 0表示当前选中窗口 其他按顺序选择
config:配置项 与Init一致
Callback:回调，暂未使用
playermode:播放模式
```
     示例
```
   CvNetVideo.StartRealTimeVideo(
                document.querySelector('#txtsim').value,
                parseInt(document.querySelector('#cmbChannel').value),
                parseInt(document.querySelector('#cmbStreamType').value),
                true,
                id,
                {
                    remoteHost: document.querySelector("#serveradd").value
                }
            );
 
```
#### 实时视频传输控制

     接口
```
AVTransferControl(Sim, Channel, ControlCommand, SwitchStreamType, TurnOffMediaType, videoId = 0, config = {});

```
   参数说明
```
具体见1078协议的0x9102项
Sim:sim卡号
Channel:通道号
ControlCommand:控制指令
SwitchStreamType:切换码流类型
TurnOffMediaType:关闭音视频类型
videoId:窗口ID 0表示当前选中窗口 其他按顺序选择
config:配置项 与Init一致
```
     示例
```
  CvNetVideo.AVTransferControl(
                document.querySelector('#txtsim').value,
                parseInt(document.querySelector('#cmbChannel').value),
                parseInt(document.querySelector('#cmbControlCommand').value),
                parseInt(document.querySelector('#cmbStreamType').value),
                parseInt(document.querySelector('#cmbTurnOffMediaType').value),
                id,
                {
                    remoteHost: document.querySelector("#serveradd").value
                }
            );
 
```
#### 发起历史视频请求

     接口
```
PlaybackVideo(Sim, Channel, MediaType, StreamType = 0, StorageType = 0, PlaybackMode = 0, Multiple = 0, StartTime, EndTime, videoId = 0, config = {}, Callback = null, playermode = 0, DataSource = 0);

```
   参数说明
```
具体见1078协议
Sim:sim卡号
Channel:通道号
MediaType:
StreamType:码流
StorageType:存储
PlaybackMode:回放模式
Multiple:倍速
StartTime:开始时间
EndTime:结束时间
videoId:窗口ID 0表示当前选中窗口 其他按顺序选择
config:配置项 与Init一致
Callback:回调，暂未使用
playermode:播放模式
DataSource:0自动 1设备 2服务端缓存
```
     示例
```
  CvNetVideo.PlaybackVideo(
                document.querySelector('#txtsim').value,
                parseInt(document.querySelector('#cmbChannel').value),
                parseInt(document.querySelector('#cmbMideaType').value),
                parseInt(document.querySelector('#cmbStreamType').value),
                parseInt(document.querySelector('#cmbStorageType').value),
                parseInt(document.querySelector('#cmbPlaybackMode').value),
                parseInt(document.querySelector('#cmbMultiple').value),
                document.querySelector('#txtStarttime').value,
                document.querySelector('#txtEndtime').value,
                id,
                {
                    remoteHost: document.querySelector("#serveradd").value
                }
            );
 
```
#### 发起历史视频控制

     接口
```
PlaybackVideoControl(Sim, Channel, PlaybackControl, Multiple, DragPlaybackPosition_Datetime, videoId = 0, config = {});

```
   参数说明
```
具体见1078协议
PlaybackControl:回放控制（0：开始回放，1：音暂停回放，2：结束回放，3：快进回放，4：关键帧快退回放，5：拖动回话，6：关键帧播放）
Multiple:快进或快退倍数（0：无效，1：1倍，2：2倍，3：4倍，4：8倍，5：16倍；回放控制为3和4时，此字段内容有效，否则置0）
DragPlaybackPosition:拖动回放位置（YY-MM-DD-HH-MM-SS，回放控制为5时，此字段有效）
```
     示例
```
 CvNetVideo.PlaybackVideoControl(
                document.querySelector('#txtsim').value,
                parseInt(document.querySelector('#cmbChannel').value),
                parseInt(document.querySelector('#cmbPlaybackControl').value),
                parseInt(document.querySelector('#cmbMultiple').value),
                document.querySelector('#txtDragPlaybackPosition').value,
                id,
                {
                    remoteHost: document.querySelector("#serveradd").value
                }
            );
 
```
#### 请求服务器视频文件列表

     接口
```
QueryVideoFileList(Sim, Channel, StartTime_utc, EndTime_utc, Alarm, MediaType, StreamType, StorageType, Callback, videoId = 0, config = {}, DataSource = 0);

```
   参数说明
```
StartTime_utc:开始时间，utc时间
EndTime_utc：结束时间，utc时间
Alarm：报警标志（bit0~bit31见JT/T 808-2011表18报警标志位定义；bit32~bit64见表13；全0表示无报警类型条件）
MediaType：音视频资源类型（0：音视频，1：音频，2：视频，3：视频或音视频）
StreamType：码流类型（0：所有码流，1：主码流，2：子码流）
StorageType：存储器类型（0：所有存储器，1：主存储器，2：灾备存储器）
DataSource:0自动 1设备 2服务端缓存
```
     示例
```
 CvNetVideo.QueryVideoFileList(
                document.querySelector('#txtsim').value,
                parseInt(document.querySelector('#cmbChannel').value),
                DateToUnixLong(document.querySelector('#txtStarttime').value),
                DateToUnixLong(document.querySelector('#txtEndtime').value),
                document.querySelector('#numAlarm').value,
                parseInt(document.querySelector('#cmbMideaType').value),
                parseInt(document.querySelector('#cmbStreamType').value),
                parseInt(document.querySelector('#cmbStorageType').value),
                QueryVideoFileListCallback,
                id,
                {
                    remoteHost: document.querySelector("#serveradd").value
                }
            );
```

#### 开始对讲
     接口
```
StartSpeek(Sim, Channel, config = {})

```
   参数说明
```
Sim:sim卡号
Channel:通道号不支持0
config:配置项 与Init一致
```
     示例
```
 CvNetVideo.StartSpeek(
                document.querySelector('#txtsim').value,
                parseInt(document.querySelector('#cmbChannel').value),
                {
                    clusterHost: document.querySelector("#txtserveradd").value,
                    clusterPort: document.querySelector("#txtport").value

                }
            );
```

#### 结束对讲

     接口
```
StopSpeak()

```
     示例
```
 CvNetVideo.StopSpeak();
```

#### 对讲音量设置
     接口
```
SetSpeekVolume(value)

```
   参数说明
```
value:音量大小 0.0-10.0 1.0是指原始音量大小，10.0是指音量放大10倍。
```
     示例
```
 CvNetVideo.SetSpeekVolume(1);
```

#### 发送FTP视频上传指令

     接口
```
FtpVideoFileUpload(Sim, Channel, FtpAddress, FtpPort, UserName, Password, FileUploadPath, StartTime, EndTime, Alarm, MediaType, StreamType, StorageType, TaskExecutionCondition, Callback, videoId = 0, config = {});

```
   参数说明
```
FtpAddress:FTP服务器地址
FtpPort：FTP服务器端口号
UserName：用户名
Password：密码
FileUploadPath：文件上传路径
StartTime：开始时间
EndTime：结束时间
Alarm：报警标志
MediaType：音视频资源类型（0：音视频，1：音频，2：视频，3：视频或音视频）
StreamType：码流类型（0：主码流或子码流，1：主码流，2：子码流）
StorageType：存储器类型（0：主存储器或灾备存储器，1：主存储器，2：灾备存储器）
TaskExecutionCondition：任务执行条件（bit0：WIFI，为1时表示WI-FI下可下载；bit1：LAN，为1时表示LAN连接时可下载；bit2：3G/4G，为1时表示3G/4G连接时可下载）
```
     示例
```
  CvNetVideo.FtpVideoFileUpload(
                document.querySelector('#txtsim').value,
                parseInt(document.querySelector('#cmbChannel').value),
                document.querySelector('#ftpAddress').value,
                parseInt(document.querySelector('#ftpPort').value), 
                document.querySelector('#ftpUsr').value, 
                document.querySelector('#ftpPwd').value,
                document.querySelector('#ftpUploadPath').value,
                ParseDate(document.querySelector('#txtStarttime').value),
                ParseDate(document.querySelector('#txtEndtime').value),
                document.querySelector('#numAlarm').value,
                parseInt(document.querySelector('#cmbMideaType').value),
                parseInt(document.querySelector('#cmbStreamType').value),
                parseInt(document.querySelector('#cmbStorageType').value),
                parseInt(document.querySelector("#taskCondition").value),
                FtpVideoFileUploadCallback,
                id,
                {
                    remoteHost: document.querySelector("#serveradd").value
                }
            );
```
#### 发送FTP视频上传控制指令

     接口
```
FtpVideoFileUploadControl(Sim, Channel, SerialNumber, UploadControl, videoId = 0, config = {});

```
   参数说明
```
SerialNumber:流水号（对应查询音视频资源列表指令的流水号）
UploadControl：上传控制（0：暂停，1：继续，2：取消）
```
     示例
```
 CvNetVideo.FtpVideoFileUploadControl(
                document.querySelector('#txtsim').value,
                parseInt(document.querySelector('#cmdSerialNumber').value),
                parseInt(document.querySelector('#cmdUploadControl').value),
                id,
                {
                    remoteHost: document.querySelector("#serveradd").value
                }
            );

```


#### 关闭或关闭所有视频
     接口
```
// 根据索引关闭窗口 0代表当前选中窗口
Stop(id);//id>=0

// 关闭所有窗口
Stop(-1);
```


#### 发送云台旋转控制指令
     接口
```
RotationControl(Sim, Channel, Direction, Speed, videoId = 0, config = {});

```
   参数说明
```
Direction:方向  0:停止 1:上 2:下 3:左 4:右
Speed:速度取值范围:0-255
```

#### 发送云台调整焦距控制指令
     接口
```
FocusControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:焦距调大 1焦距调小
```

#### 发送云台调整光圈控制指令
     接口
```
ApertureControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:调大 1调小
```

#### 发送云台雨刷控制指令
     接口
```
WiperControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:停止 1:启动
```
#### 发送云台红外补光控制指令
     接口
```
InfraredControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:停止 1:启动
```

#### 发送云台变倍控制指令
     接口
```
TimesControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:调大 1调小
```

#### 获取历史流播放缓存
     接口
```
GetPlayBackCacheTime(videoId = 0);

```
   参数说明
```
videoId:窗口ID 0表示当前选中窗口 其他按顺序选择
```
     返回
```
 {
     //已播放时长(毫秒)
     playedMs,
     //已缓冲未播放时长(毫秒)
     waitingPlayMs
 }
```

#### Gov播放
     接口
```
GovPlay(url, videoId = 0, config = {}, Callback = null);

```
   参数说明
```
url: JT/T 1078-2016 6.2中规定的URL
videoId:哪一个分屏，0代表当前选中分屏 
config:配置项 可更改init中传入config值
Callback:错误回调 function (status, reason) 
	-1, "URL请求发生错误"
	-2, "URL请求失败"
	-101, "超过允许最大连接数，断开连接"
	-102, "超过允许播放时长，断开连接。"
```

示例
```js
CvNetVideo.GovPlay(
                "http://et.test.cvtsp.com:15007/沪QQ7771.1.1.0.aaa",
                id, null,
                //gov实时流请求回调，status < 0 请求失败，reason 原因
                function (status, reason) {
                    if (status < 0) {
                        console.log("失败:" + reason);
                        if (status == -1) {
                            alert("URL请求发生错误，请检查URL是否能访问，或是否通过HTTPS页面访问了HTTP地址。");
                        } else {
                            alert(reason);
                        }
                    }
                },
            );
```

#### 下载历史视频文件
     接口
```
DownLoadVideo(Sim, Channel, MediaType, StreamType = 0, StorageType = 0, PlaybackMode = 0, Multiple = 0, StartTime, EndTime, config = {}, DataSource = 0, Speed = 4, VideoFormat = 0) ;

```
   参数说明
```
Sim:sim卡号
Channel:通道号不支持0
MediaType：音视频资源类型（0：音视频，1：音频，2：视频，3：视频或音视频）
StreamType：码流类型（0：主码流或子码流，1：主码流，2：子码流）
StorageType：存储器类型（0：主存储器或灾备存储器，1：主存储器，2：灾备存储器）
PlaybackMode:回放模式（0：正常回放，1：快进回放，2：关键帧快退回放，3：关键帧播放，4：单帧上传）
Multiple:倍速（0：无效，1：1倍，2：2倍，3：4倍，4：8倍，5：16倍）
StartTime:开始时间
EndTime:结束时间
config:配置项 与Init一致
DataSource:0自动 1设备 2服务端缓存
Speed:下载倍速，仅28181有效
VideoFormat:文件格式（0：FMP4格式，1：FLV格式）
```


#### 下载FMP4文件
     接口
```
DownLoadFmp4(Sim, Channel, MediaType, StreamType = 0, StorageType = 0, PlaybackMode = 0, Multiple = 0, StartTime, EndTime, config = {}, DataSource = 0, Speed = 4) ;

```
   参数说明
```
Sim:sim卡号
Channel:通道号不支持0
MediaType：音视频资源类型（0：音视频，1：音频，2：视频，3：视频或音视频）
StreamType：码流类型（0：主码流或子码流，1：主码流，2：子码流）
StorageType：存储器类型（0：主存储器或灾备存储器，1：主存储器，2：灾备存储器）
PlaybackMode:回放模式（0：正常回放，1：快进回放，2：关键帧快退回放，3：关键帧播放，4：单帧上传）
Multiple:倍速（0：无效，1：1倍，2：2倍，3：4倍，4：8倍，5：16倍）
StartTime:开始时间
EndTime:结束时间
config:配置项 与Init一致
DataSource:0自动 1设备 2服务端缓存
Speed:下载倍速，仅28181有效
```


### 其他
#### 截图
     接口
```
// 截图
Capture(filename, captureType, captureQuality, videoId = 0);

```
   参数说明
```
filename:为null时不下载生成文件
captureType:截图图片类型 0 png, 1 jpeg, 2 webp; 为null时取config.captureType
captureQuality:截图图片质量 0-1 jpeg和webp时有效; 为null时取config.captureQuality
videoId:0为选中窗口，其它为窗口索引号从1开始
return:截图图片base64编码
```
#### 刷新
     接口
```
// 刷新(跳到最新画面播放)
Refreash(videoId = 0);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
```

#### 暂停
     接口
```
// 暂停
Pause(videoId = 0);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
```

#### 恢复播放
     接口
```
// 恢复播放
Resume(videoId = 0);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
```

#### 获取音量
     接口
```
// 获取音量
GetVolume(videoId = 0);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
return:0-100，100最大
```

#### 设置音量
     接口
```
// 设置音量
SetVolume(videoId, volume);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
volume:0-100，100最大
```

#### 全屏
     接口
```
// 设置分屏全屏
SetFull(videoId, is_full);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
is_full:true 全屏 false 取消全屏
```

#### 开始录像
     接口
```
// 开始录像
StartRecord(videoId = 0);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
```

#### 停止录像
     接口
```
// 停止录像
StopRecord(videoId = 0);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
```

#### 设置视频宽高比
     接口
```
// 设置视频宽高比，WASM和Codec模式暂未支持
SetAdaptRatio(videoId , is_adapt);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
is_adapt:true 保持视频宽高比;false 铺满分屏
```

#### 设置播放速度
     接口
```
// 设置播放速度
SetPlaySpeed(videoId , speed);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
speed:必须大于0，1为正常倍速，支持小数
```

#### 视频旋转
     接口
```
// 根据索引关闭窗口 0代表当前选中窗口
SetRotate(id, angle);//id>=0

```
   参数说明
```
id:0为选中窗口，其它为窗口索引号从1开始
angle:旋转角度，只支持0，90，180，270其它传入值无效
return:true为调用成功，false为调用失败
```

#### 视频镜面反转
     接口
```
// 初始化为正常状态，之后调用一次反转一次
SetMirrorInver(id);//id>=0

```
   参数说明
```
id:0为选中窗口，其它为窗口索引号从1开始
return:true为调用成功，false为调用失败
```

#### 整体全屏
     接口
```
// 保持分屏整体全屏 
FullScreen()

```

#### 放大单个分屏
     接口
```
// 将单个分屏铺满整个控件 同双击分屏事件
ZoomUC(videoId)

```
   参数说明
```
videoId:-1为所有窗口，0为选中窗口，其它为窗口索引号从1开始
```

#### 恢复分屏
     接口
```
// 恢复显示所有分屏 
UnZoomUC()

```


#### 重新设置大小
     接口
```
// 重新设置播放控件整体所占用大小
Resize(width, height)

```
   参数说明
```
width:宽度
height:高度
```


#### 视频镜面反转
     接口
```
// 初始化为正常状态，之后调用一次反转一次
SetMirrorInver(id);//id>=0

```
   参数说明
```
id:0为选中窗口，其它为窗口索引号从1开始
return:true为调用成功，false为调用失败
```

#### osd显示开关
     接口
```
// 设置所有分屏osd是否显示
SetOsdVisible(visible, videoId);

```
   参数说明
```
visible:true 显示/false 隐藏
videoId:-1为所有窗口，0为选中窗口，其它为窗口索引号从1开始
```

#### osd文本颜色
     接口
```
// 设置所有分屏osd文本颜色
SetOsdColor(color, videoId);

```
   参数说明
```
color: 颜色代码，例如"#00ff00"
videoId:-1为所有窗口，0为选中窗口，其它为窗口索引号从1开始
```
#### osd文本
     接口
```
// 设置所有分屏osd文本颜色
SetOsdText(videoId, text);

```
   参数说明
```
videoId:-1为所有窗口，0为选中窗口，其它为窗口索引号从1开始
text: 文本内如
```

#### 是否播放
     接口
```
// 分屏是否正在播放(只要开启不管有无画面均认为在播放，手动暂停此状态还是true)
IsPlaying(videoId);

```
   参数说明
```
videoId:0为选中窗口，其它为窗口索引号从1开始
return: true 播放中 false 未播放
```

#### 设置超时时间
     接口
```
// 设置超时时间
SetTimeoutMsec(timeoutCloseMsec, timeoutWarningMsec);

```
   参数说明
```
timeoutCloseMsec: 超时关闭时间
timeoutWarningMsec: 超时前警告提醒时间
```
#### 设置优先级
     接口
```
// 设置优先级
SetPriority(priority, videoId = 0);

```
   参数说明
```
priority: 优先级0-100 越大优先级越高
videoId:0为选中窗口，其它为窗口索引号从1开始
```

### UCMain包含属性
#### Videos
```
// 获取内部分屏对象 即内部UCVideo对象，一个分屏就是一个UCVideo
Videos[id]

```
   参数说明
```
id:索引号从1开始
return:UCVideo对象
```

#### NowSelectVideo
```
// 当前选中分屏id

```


#### NowPlayVideosCount
```
// 当前播放中的分屏数量

```


## 功能测试页面

[js控件测试页面](test/)
