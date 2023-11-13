 * [主动安全附件服务](#主动安全附件服务)
      * [接入流程](#接入流程)
      * [附件上传完成通知](#附件上传完成通知)
         * [kafka通知](#kafka通知)
         * [阿里云OSS通知](#阿里云OSS通知)

# 客户端认证
RTVS的客户端和服务端默认情况下并没有做验证，只要知道服务端的地址和端口后即可请求。如果需要拦截掉未授权的请求，可以有以下几种方式。


## Ctag
RTVS的JSSDK请求时，可以传入一个Ctag，这个Ctag传递给后台后，会一路传给网关接口地址，这就可以在网关接口地址做验证，未通过验证的可以直接应答失败即可。

但此方法有一个缺陷，即实时视频如果复用时，不会调用网关接口，这时候是直接通过的。


## 一次性Token认证
启用ClientAuth后，RTVS支持一次性Token认证，tokenType 1。

在后端接口中支持申请一次性Token，默认5分钟内有效，使用后失效。此Token可通过JSSDK请求时传入，验证通过才放行。

启用ClientAuth配置
``` bash
export RTVS_CLIENT_AUTH=true
```

JSSDK通过config传入下面参数
``` js
tokenType: 1,
token: "一次性Token",
```

## RSA加密时间戳认证
启用ClientAuth后，RTVS支持RSA加密时间戳认证，tokenType 2。

需要一对RSA证书，加密过程如下：
```
//加密过程
//1.取当前UTC时间戳(秒) 转换为二进制数据(8字节 无符号 高位在前)
//2.用公钥加密
//3.加密结果用BASE64编码
```
注：私钥和公钥都不能泄露，所以不要用域名的证书。


配置过程：
启用ClientAuth配置和配置RSA私钥证书
``` bash
export RTVS_CLIENT_AUTH=true
export RTVS_CARSA_PEMKEY_PATH="RSA私钥证书路径"
```


JSSDK通过config传入下面参数
``` js
tokenType: 2,
token: "BASE64编码的时间戳加密结果",
```
