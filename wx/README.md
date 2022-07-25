 # RTVS小程序说明
小程序中调用RTVS可以有两种方式

1.用webviewer方式调用网页方式，此方式支持RTVS全部功能，缺陷是webviewer无法与小程序通信。

2.用rtvs.wx.js获取RTMP地址后配合live-player播放，此方式仅支持实时和历史播放，不支持对讲等功能。另外微信对live-player使用有限制，必须特定行业的企业账号才能使用，具体查看微信文档。

示例代码片段，请在微信开发工具中导入：

> https://developers.weixin.qq.com/s/1oRqF0ml7MBS
> 

体验地址，对应服务器为 et.test.cvtsp.com:15001

![体验小程序](xcx.jpg)

## 注意事项
微信小程序只支持WSS，需要对RTVS支持WSS，请参考RTVS证书配置部分。

微信公众平台需要在开发设置中配置服务器域名,socket合法域名端口一般是17000和6005

## rtvs.wx.js接口说明

### 构造

``` javascript
constructor(config);
```
config说明
``` javascript
config = {
        //服务器地址
        clusterHost,
        //服务器端口
        clusterPort,
        //事件通知
        events: {

          //设备开始传输视频事件
          //参数1 id 一直为null
          //参数2 rtvs_wx对象
          onDevConnect: function (id, ucVideo) {
          },


          //设备断开传输视频事件
          //参数1 id 一直为null
          //参数2 rtvs_wx对象
          onDevDisconnect: function (id, ucVideo) {
          },


          //Websocket通道关闭事件
          //参数1 id 一直为null
          //参数2 rtvs_wx对象
          onWsClose: function (id, ucVideo) {
          },


          //服务端通知事件
          //参数1 事件类型 字符串(onDevConnect onDevDisconnect onWsClose)之一
          //参数2 id 一直为null
          //参数3 rtvs_wx对象
          onServerNotice: function (type, id, ucVideo) {
          },


          //服务端结束
          //参数1 结束原因 字符串
          //参数2 id 一直为null
          //参数3 rtvs_wx对象
          //返回值表示是否取消自动停止，为真时表示取消
          onEndByServer: function (msg, id, ucVideo) {
          }
        }
      }
```

示例
``` javascript
    const rtvs_wx = require('../../lib/rtvs.wx');
    this.uc = new rtvs_wx(
      {
        //服务器地址
        clusterHost: "et.test.cvtsp.com",
        //服务器端口
        clusterPort: 15001,
        //事件通知
        events: {

          //设备开始传输视频事件
          //参数1 id 一直为null
          //参数2 rtvs_wx对象
          onDevConnect: function (id, ucVideo) {
            this.changeStatusText("设备连接");
          }.bind(this),


          //设备断开传输视频事件
          //参数1 id 一直为null
          //参数2 rtvs_wx对象
          onDevDisconnect: function (id, ucVideo) {
            this.changeStatusText("设备断开连接");
          }.bind(this),


          //Websocket通道关闭事件
          //参数1 id 一直为null
          //参数2 rtvs_wx对象
          onWsClose: function (id, ucVideo) {
            this.changeStatusText("与服务器通信结束");
          }.bind(this),


          //服务端通知事件
          //参数1 事件类型 字符串(onDevConnect onDevDisconnect onWsClose)之一
          //参数2 id 一直为null
          //参数3 rtvs_wx对象
          onServerNotice: function (type, id, ucVideo) {
            console.log("event:" + type);
          }.bind(this),


          //服务端结束
          //参数1 结束原因 字符串
          //参数2 id 一直为null
          //参数3 rtvs_wx对象
          //返回值表示是否取消自动停止，为真时表示取消
          onEndByServer: function (msg, id, ucVideo) {
            console.log("播放结束，原因：" + msg);
            this.changeStatusText("播放结束，原因：" + msg);
          }.bind(this)
        }
      });

```

### 发起实时视频
接口
```
StartRealTimeVideo(Callback, Sim, Channel, streamType = 1, hasAudio = true);
```
   参数说明
```
Callback:获取到RTMP地址的回调，回调参数rtmp_url
Sim:sim卡号/设备手机号
Channel:通道号不支持0
streamType:主子码流( 0 主码流 1 子码流)
hasAudio:是包含音频
```

示例
``` javascript
      this.uc.StartRealTimeVideo(function (rtmp_url) {
      console.log(rtmp_url);
      this.setData({
        rtmpurl: rtmp_url
      })
      this.ctx.play({
        success: res => {
          console.log('play success')
        },
        fail: res => {
          console.log('play fail')
        }
      })
    }.bind(this), this.data.Sim, this.data.multiIndex[0]+1, this.data.multiIndex[1], mideaType);
```


### 发起历史视频
接口
```
PlaybackVideo(Callback, Sim, Channel, MediaType, StreamType = 0, StorageType = 0, PlaybackMode = 0, Multiple = 0, StartTime, EndTime = "", DataSource = 0) 
```
   参数说明
```
Callback:获取到RTMP地址的回调，回调参数rtmp_url
Sim:sim卡号/设备手机号
Channel:通道号不支持0
MediaType:音视频类型 (0 音视频, 1 音频 , 2 视频 , 3 音频或视频)
StreamType:码流类型 (0 所有码流 , 1 主码流 , 2 子码流)
StorageType:0 主存储器或灾备存储器 , 1 主存储器 , 2 灾备储器
PlaybackMode: 0 正常回放 , 1 快进回放 , 2 关键帧快退回放 , 3 关键帧播放 , 4 单帧上传
Multiple: 1 '1倍' , 2 '2倍' , 3 '4倍' , 4 '8倍' , 5 '16倍'
StartTime: 开始时间 yyyy-MM-dd HH:mm:ss格式
EndTime: 结束时间 yyyy-MM-dd HH:mm:ss格式
DataSource: 0 默认 1 设备 2 服务器缓存
```

示例
``` javascript
      this.uc.PlaybackVideo(function (rtmp_url) {
      console.log(rtmp_url);
      this.setData({
        rtmpurl: rtmp_url
      })
      this.ctx.play({
        success: res => {
          console.log('play success')
        },
        fail: res => {
          console.log('play fail')
        }
      })
    }.bind(this),
      this.data.Sim, this.data.multiIndex[0] + 1, this.data.multiIndex[2],
      this.data.multiIndex[1], this.data.multiIndex[3], this.data.multiIndex[4], this.data.multiIndex[5] + 1,
      this.data.startTime, this.data.endTime, this.data.multiIndex[6]);
```


### 停止
接口
```
Stop()
```

示例
``` javascript
    this.uc.Stop();
```

