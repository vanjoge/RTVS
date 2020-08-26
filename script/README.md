# 启动脚本
以下在Centos7下测试通过，其他环境可能需要修改docker_network.sh脚本，主要需解决docker容器访问宿主机"No route to host"问题。

需支持lsof命令
1. 添加docker自定义网络(仅首次需要)
```
sudo ./docker_network.sh
```
2. 启动集群管理
```bash
#DOCKER_HTTP_PORT HTTP映射端口 默认30888
#DOCKER_HTTP_PORT=30888
#DOCKER_WEBSOCKET_PORT 设备连接端口 默认17000
#DOCKER_WEBSOCKET_PORT=17000

sudo -E ./run_cluster.sh
```
3. 启动rtvs
``` bash
#设置服务器IP地址或域名
export IPADDRESS=10.10.10.228
#设置服务器对应备案域名，防止某些IDC对未备案IP拦截，如果不设置则取IPADDRESS值。
export BeianAddress=yourdomain.xxx
#设置网关接口地址
export GatewayBaseAPI=http://10.10.10.110:8888/WebService/
#设置redis连接字符串
export RedisExchangeHosts=10.10.10.126:7000,10.10.10.126:7001,10.10.10.126:7002,10.10.10.126:7003,10.10.10.126:7004,10.10.10.126:7005,connectTimeout=20000,syncTimeout=20000,responseTimeout=20000

#其他参数请自定查看脚本 一般无需修改
sudo -E ./run_rtvs.sh
```

