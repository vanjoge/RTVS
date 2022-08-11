 * [主动安全附件服务](#主动安全附件服务)
      * [接入流程](#接入流程)
      * [附件上传完成通知](#附件上传完成通知)
         * [kafka通知](#kafka通知)
         * [阿里云OSS通知](#阿里云OSS通知)

# 主动安全附件服务
RTVS已集成主动安全附件服务，支持团标，同时支持苏、粤、陕、赣、川、浙等地方标准

执行标准
> T/JSATL12—2017 道路运输车辆主动安全智能防控系统 （通讯协议规范）
>
> CSAET/CSAE 243.2—2021 道路运输车辆主动安全智能防控系统第2 部分：通讯协议要求
> 
> T/SCSDX 0001—2019 道路运输车辆主动安全智能防控系统技术规范
> 
> T/ZJRTA 03—2018 道路运输车辆智能视频监控报警系统通讯协议规范
>
> T/GDRTA 002—2020 粤标(20位SIM卡号)
> 
> ...

## 接入流程
只需将808网关中**报警附件上传指令(0x9208)** 中 **附件服务器IP地址** 和 **附件服务器端口** 设置为RTVS提供的服务即可。

**附件服务器IP地址** 一般为部署RTVS所在服务器的IP

**附件服务器端口** 默认值为6030

## 附件上传完成通知
### kafka通知
#### 配置kafka
启用kafka需要设置以下参数

|  参数名   | 默认值|
|  ----  | ----  |
| KafkaServer  | 无 |  
| DOCKER_ATTACHMENT_KafkaTopic  | media-complete |  

例如: run_all.sh 脚本中加入以下脚本配置kafka连接信息
kafka各设置名称可参考此处 https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md
``` bash
export KafkaServer="bootstrap.servers=192.168.1.11:9092"
```
#### 通知格式
配置kafka连接信息后，附件服务会在收全一个文件后会通过kafka生成一个通知，通知格式如下：

``` 
class AttachNotify
{
        /// <summary>
        /// 附件文件大小
        /// </summary>
        public long FileLength { get; set; }
        /// <summary>
        /// 相对路径 也是上传到OSS的路径
        /// </summary>
        public string RelativePath { get; set; }
        /// <summary>
        /// 报警ID
        /// </summary>
        public string AlarmID { get; set; }
        /// <summary>
        /// 附件地址
        /// </summary>
        public string AttachPath { get; set; }
        /// <summary>
        /// 附件状态   0:失败  1:成功
        /// </summary>
        public byte Status { get; set; }
}
```
示例
``` json
{
	"FileLength": 737407,
	"RelativePath": "20220811/023112345678/01_64_6402_01_4997506747182612826.h264",
	"AlarmID": "4997506747182612826",
	"AttachPath": "http://localhost:5008/alarmfiles/20220811/023112345678/01_64_6402_01_4997506747182612826.h264",
	"Status": 1
}
```

### 阿里云OSS通知
主动安全附件服务支持将附件文件写入阿里云OSS，只需按以下配置即可
#### 配置阿里云OSS写入

启用阿里云OSS需要设置以下参数

|  参数名   | 默认值|
|  ----  | ----  |
| DOCKER_ATTACHMENT_AliOssEndpoint  | 无 |  
| DOCKER_ATTACHMENT_AliOssAccessKeyId  | 无 |  
| DOCKER_ATTACHMENT_AliOssAccessKeySecret  | 无 |  
| DOCKER_ATTACHMENT_AliOssBucket  | 无 |  

例如: run_all.sh 脚本中加入以下内容

``` bash
export DOCKER_ATTACHMENT_AliOssEndpoint="https://oss-cn-beijing.aliyuncs.com"
export DOCKER_ATTACHMENT_AliOssAccessKeyId="yourAccessKeyId"
export DOCKER_ATTACHMENT_AliOssAccessKeySecret="yourAccessKeySecret"
export DOCKER_ATTACHMENT_AliOssBucket="examplebucket"

```


#### 配置OSS写入完成回调

需设置以下参数
**注:阿里云要求回调URL返回内容是json格式**

|  参数名   | 默认值|
|  ----  | ----  |
| DOCKER_ATTACHMENT_AliOssCallbackUrl  | 无 |  


例如: run_all.sh 脚本中加入以下内容

``` bash
export DOCKER_ATTACHMENT_AliOssCallbackUrl="http://oss-demo.aliyuncs.com:23450"

```

如果配置了阿里云OSS写入，并配置有回调URL，阿里云会在附件成功上传到OSS之后发送Post到回调URL，通知格式如下：
```
bucket={bucket}&object={oss路径}&etag={etag}&size={size}&mimeType={mimeType}&AlarmID={主动安全报警ID}
```

