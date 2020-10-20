JS视频播放插件
===
环境说明
----
引用
```
 <script type="text/javascript" src="http://lib.cvtsp.com/video/CVNetVideoJs/1.2.0/CvNetVideo.js"></script>

```
API说明
===
初始化控件
----
   接口
```
CvNetVideo.Init(dom, VideoNums = 4, config = {});

```
   参数说明
```
dom:视频控件插入节点，一般是div
VideoNums:显示视频控件数量，后期可调整，支持1, 4, 6, 9, 10, 16
config:配置项
defaultConfig = {
                //以下只可初始化传入 后期不可改
                //与dom参数一致 
                media: null,
                //视频显示宽度
                videoWidth: 352,
                //视频显示高度
                videoHeight: 288,
                //wasm库加载地址
                libffmpegUrl: "/Scripts/libffmpeg.js",
                //css地址 如需修改控件样式，请自行指定css地址
                cssUrl: "/css/CVNetVideo.css",
                recordVideo: false,
                screenshot: false,
                yuntaiCtrl: false,
                networkSpeaking: true,


                //以下参数可调用方法时修改


                //0 自动 1 WASM软解(canvas+audioAPI) 2 js封装FMP4(h264Demuxer+audioAPI) 3 WASM封装FMP4(WASM2FMP4) 4 服务器推fmp4流 5 webrtc 6 hls
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
                //
                maxPcmQueueCount: 30,
                //播放过程中是否显示正在加载loading框
                showLoadingByPlay: true,
                //追帧模式 0 跳到最新 其他 倍速加速
                seekMode: 1,
                //最大允许延迟秒 超过则开始追帧
                maxDelay: 2,
                //选中事件
                selectedEvent: null
            };
```
   示例

```
window.onload = function () {
            console.log(CvNetVideo.version);
            //this.setTimeout(init, 2000);
            init();

        };
        function init() {
            CvNetVideo.Init(document.querySelector("#player"), 4,
                {
                    remoteHost: "127.0.0.1",
                    playerMode: 4,
                    callback: function () {
                        [].forEach.call(document.querySelectorAll("button"), function (btn) {
                            btn.disabled = false;
                        });
                    },
                    libffmpegUrl:"/Scripts/libffmpeg.js"
                });
       }
```

发起实时视频
----
     接口
```
StartRealTimeVideo(Sim, Channel, streamType = 1, hasAudio = true, videoId = 0, config = {});
```
   参数说明
```
Sim:sim卡号
Channel:通道号不支持0
streamType:主子码流 0 主码流 1 子码流
hasAudio:是否打开音频
videoId:窗口ID 0表示当前选中窗口 其他按顺序选择
config:配置项 与Init一致
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
实时视频传输控制
----
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
发起历史视频请求
----
     接口
```
PlaybackVideo(Sim, Channel, MediaType, StreamType = 0, StorageType = 0, PlaybackMode = 0, Multiple = 0, StartTime, EndTime, videoId = 0, config = {});

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
发起历史视频控制
----
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
请求服务器视频文件列表
----
     接口
```
QueryVideoFileList(Sim, Channel, StartTime_utc, EndTime_utc, Alarm, MediaType, StreamType, StorageType, Callback, videoId = 0, config = {});

```
   参数说明
```
StartTime_utc:开始时间，utc时间
EndTime_utc：结束时间，utc时间
Alarm：报警标志（bit0~bit31见JT/T 808-2011表18报警标志位定义；bit32~bit64见表13；全0表示无报警类型条件）
MediaType：音视频资源类型（0：音视频，1：音频，2：视频，3：视频或音视频）
StreamType：码流类型（0：所有码流，1：主码流，2：子码流）
StorageType：存储器类型（0：所有存储器，1：主存储器，2：灾备存储器）
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

发送FTP视频上传指令
----
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
发送FTP视频上传控制指令
----
     接口
```
FtpVideoFileUploadControl(Sim, SerialNumber, UploadControl, videoId = 0, config = {});

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

设置分屏数量
----
     接口
```
 LayoutByScreens(num);

```
   参数说明
```
num:支持1, 4, 6, 8, 9, 10, 13, 16
```
      示例
```
 CvNetVideo.LayoutByScreens(num);

```

关闭或关闭所有视频
----
     接口
```
// 根据索引关闭窗口 0代表当前选中窗口
CvNetVideo.Stop(id);//id>=0

// 关闭所有窗口
CvNetVideo.Stop(-1);
```

视频旋转
----
     接口
```
// 根据索引关闭窗口 0代表当前选中窗口
CvNetVideo.SetRotate(id, angle);//id>=0

```
   参数说明
```
id:0为选中窗口，其它为窗口索引号从1开始
angle:旋转角度，只支持0，90，180，270其它传入值无效
return:true为调用成功，false为调用失败
```

视频镜面反转
----
     接口
```
// 初始化为正常状态，之后调用一次反转一次
CvNetVideo.SetMirrorInver(id);//id>=0

```
   参数说明
```
id:0为选中窗口，其它为窗口索引号从1开始
return:true为调用成功，false为调用失败
```


发送云台旋转控制指令
----
     接口
```
RotationControl(Sim, Channel, Direction, Speed, videoId = 0, config = {});

```
   参数说明
```
Direction:方向  0:停止 1:上 2:下 3:左 4:右
Speed:速度取值范围:0-255
```

发送云台调整焦距控制指令
----
     接口
```
FocusControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:焦距调大 1焦距调小
```

发送云台调整光圈控制指令
----
     接口
```
ApertureControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:调大 1调小
```

发送云台雨刷控制指令
----
     接口
```
WiperControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:停止 1:启动
```
发送云台红外补光控制指令
----
     接口
```
InfraredControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:停止 1:启动
```
发送云台变倍控制指令
----
     接口
```
TimesControl(Sim, Channel, Flag, videoId = 0, config = {});

```
   参数说明
```
Flag:0:调大 1调小
```

功能测试页面
===
[js控件测试页面](test/)
