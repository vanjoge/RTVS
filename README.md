
   * [RTVS](#rtvs)
      * [特色：](#特色)
      * [测试地址](#测试地址)
      * [更新](#更新)
      * [运行方法](#运行方法)
      * [部署示例](#部署示例)
      * [808平台接入指南](#808平台接入指南)
      * [测试情况](#测试情况)
         * [延迟测试](#延迟测试)
         * [移动端测试](#移动端测试)
         * [前端播放性能测试](#前端播放性能测试)
         * [压力测试](#压力测试)

# RTVS
低延迟、跨平台、无插件、高性能的完整商业级1078视频平台

执行标准
> JT/T 1077-2016 道路运输车辆卫星定位系统 视频平台技术要求
> 
> JT/T 1078-2016 道路运输车辆卫星定位系统 视频通讯协议
> 
> JT/T 1078-2014 道路运输车辆卫星定位系统视频通迅协议标准报批稿(仅视频)

支持音频格式
> G711A
> 
> G711U
>  
> G726 40K,32k,24k,16k (支持自动预测)
> 
> ADPCMA
> 
> AMR_NB(仅解码)

## 项目地址

[https://github.com/vanjoge/RTVS](https://github.com/vanjoge/RTVS)
[https://gitee.com/vanjoge/RTVS](https://gitee.com/vanjoge/RTVS)


## 特色：
1. **全平台**(Windows、Linux、Mac、Android、IOS、微信小程序等)无需插件支持，**支持H5无插件对讲**，可用于多种浏览器，非flex和flv.js方案，无需担心flash支持过期和IOS支持问题；
2. 低延迟模式可达200ms内，且无累积延迟，均为**硬解**，浏览器CPU占用更低；
3. 性能优秀，单节点**4核8G**即可通过交通部压力测试，即至少200路并发视频；
4. 前端封装为js控件，集成播放UI与信令接口，接入简单，二次开发也十分方便，同时集成常用播放器按钮，并支持拖动切换分屏；
5. 支持多种播放模式(FMP4/Webrtc/RTMP/HLS)，并支持自动根据当前浏览器环境选择最优方案；
6. 后端为标准接口，方便与其他家808平台对接，默认带一个808测试网关，可**开箱即用**；
7. 支持服务端缓存，播放/上传过的历史视频无需从设备传输；
8. 集群、不停机更新支持，**可横向扩展支撑超大规模设备接入**；
9. C/S控件可用于OCX或C/S客户端，支持直接播放1078 RTP流，1078Http流，并支持本地录像为MP4等过检必需要求；
10. 18年已通过1077平台标准符合性检测；
11. 完整运维后台支持，每一次视频请求均有记录，运维人员通过日志可快速定位问题，无需开发人员参与；
12. **支持4K**实时/历史视频。

![拖拽切换](test/img/drag.gif)


## 测试地址


[HTTP地址](http://lib.cvtsp.com/video/CVNetVideoJs/test/tstrtvs.html)


[可对讲HTTPS地址](https://lib.cvtsp.com/video/CVNetVideoJs/test/tstrtvs.html)

默认手机号为一个模拟设备，不一定随时打开着，建议自己挂一台真实设备上去，也方便看延迟。


## 更新

```diff

+ 20200909更新为1.2.0
++ 1.支持H5对讲(需HTTPS或本地文件网页，否则无法获取麦克风);
++ 2.JS控件支持默认按浏览器类型自动选择播放模式，支持不同分屏使用不同播放模式；
++ 3.支持SSL，加载证书后WS和WSS复用同一端口；
++ 4.其他bug修复。

+ 20200828加入测试808网关，支持开箱即用。
```

## 运行方法
RTVS可部署版本已打包成docker镜像并上传到dockerhub，可以通过本项目的启动脚本可快速运行RTVS。

[启动脚本见此文档](script/README.md)

## 部署示例

[阿里云部署例子](https://blog.csdn.net/vanjoge/article/details/108319078)


## 808平台接入指南
[前端页面接入文档](JsAccess.md)

[js控件测试页面说明](test/)


[后台接入文档](Platform808Access.md)




## 测试情况

> Windows： Chrome Firefox  
> Linux： Chrome Firefox  
> Android： Chrome Firefox 微信网页 QQ网页  
> Mac： Safari Chrome  
> IOS： Safari

### 延迟测试
电脑端开一个计时秒表，用设备的摄像头对着秒表，然后对电脑屏幕截图，将秒表时间与播放画面时间相减就可得到延迟值，从截图来看，基本都在200ms内，且不存在累积延迟。

*注：延迟与设备和网络均有关系，这里的测试环境是设备通过有线连接，服务端为远端IDC机房，其他环境延迟值更低或更高均有可能。* 

> Windows Chrome
![windows Chrome](test/img/Windows_Chrome.jpg)

> Windows Firefox
![windows firefox](test/img/Windows_Firefox.jpg)

> Linux Chrome
![Linux chrome](test/img/Linux_Chrome.jpg)

### 移动端测试 
> Android Firefox
![Android Firefox](test/img/Android_Firefox.jpg)

> Android Chrome
![Android Chrome](test/img/Android_Chrome.jpg)


### 前端播放性能测试

> 16路720P实时视频，Windows Chrome，硬解。
> 
> 测试机 I7-5500U 940M 8G 
> 
> Chrome CPU占用约 65% GPU 40% 
![16路720P](test/img/PlayStress.jpg)

### 压力测试

> 测试机 I7-5500U 940M 8G 
> 200路收发
![压力截图](test/img/Stress.png)




QQ交流群：614308923
