# RTVS
低延迟、跨平台、无插件的商业级1078视频平台

执行标准
> JT/T 1077-2016 道路运输车辆卫星定位系统 视频平台技术要求
> 
> JT/T 1078-2016 道路运输车辆卫星定位系统 视频通讯协议

## 启动脚本
[启动脚本见此文档](script/README.md)


## 808平台接入指南
[前端页面接入文档](JsAccess.md)

[后台接入文档](Platform808Access.md)



## 特色：
1. 无需插件支持，可用于多种浏览器，非FLV或HTTP-FLV方案，不用担心flash支持过期和IOS不支持问题；
2. 绝大部分操作系统(PC、手机)都可以支持；
3. 低延迟，可达200ms内，且无累积延迟；
4. 硬解支持，CPU占用更低；
5. 前端封装为js控件，集成播放UI与信令接口，接入简单，二次开发也十分方便；
6. 后端为标准接口，方便与其他家808平台对接；
7. 集群、不停机更新支持；
8. C/S控件可用于OCX或C/S客户端，支持直接播放1078 RTP流；
9. 18年已通过1077平台标准符合性检测。

## 已测试

> Windows： Chrome Firefox  
> Linux： Chrome Firefox  
> Android： Chrome Firefox 微信网页 QQ网页  
> Mac： Safari Chrome  
> IOS： Safari

## 延迟测试
电脑端开一个计时秒表，用设备的摄像头对着秒表，然后对电脑屏幕截图，将秒表时间与播放画面时间相减就可得到延迟值，从截图来看，基本都在200ms内，且不存在累积延迟。

*注：延迟与设备和网络均有关系，这里的测试环境是设备通过有线连接，服务端为远端IDC机房，其他环境延迟值更低或更高均有可能。* 

> Windows Chrome
![windows Chrome](https://img-blog.csdnimg.cn/20200817154414395.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3ZhbmpvZ2U=,size_16,color_FFFFFF,t_70#pic_center)

> Windows Firefox
![windows firefox](https://img-blog.csdnimg.cn/20200817154454106.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3ZhbmpvZ2U=,size_16,color_FFFFFF,t_70#pic_center)

> Linux Chrome
![Linux chrome](https://img-blog.csdnimg.cn/20200817170544901.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3ZhbmpvZ2U=,size_16,color_FFFFFF,t_70#pic_center)

## 移动端测试 
> Android Firefox
![Android Firefox](https://img-blog.csdnimg.cn/20200820104203412.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3ZhbmpvZ2U=,size_16,color_FFFFFF,t_70#pic_center)

> Android Chrome
![Android Chrome](https://img-blog.csdnimg.cn/2020082010424656.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3ZhbmpvZ2U=,size_16,color_FFFFFF,t_70#pic_center)


## 前端播放性能测试

> 16路720P实时视频，Windows Chrome，硬解。
![16路720P](https://img-blog.csdnimg.cn/20200820101716110.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3ZhbmpvZ2U=,size_16,color_FFFFFF,t_70#pic_center)

QQ交流群：614308923
