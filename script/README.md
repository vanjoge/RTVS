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
3. (可选)开启测试网关

为了方便演示，我放了一个已经和RTVS对接808网关，可通过以下脚本步骤启动，此脚本会自动启动一个redis，连接地址为172.29.108.245:6379
``` bash

sudo -E run_gw.sh
```


4. 启动rtvs
``` bash
#设置服务器IP地址或域名(内网测试无需映射端口 外网请映射端口)
export IPADDRESS=10.10.10.228
#设置服务器对应备案域名，防止某些IDC对未备案IP拦截，如果不设置则取IPADDRESS值。
export BeianAddress=yourdomain.xxx
#设置网关接口地址
export GatewayBaseAPI=http://172.29.108.249/api/
#设置redis连接字符串
export RedisExchangeHosts=172.29.108.245:6379,connectTimeout=20000,syncTimeout=20000,responseTimeout=20000

#其他参数请自行查看脚本 一般无需修改
sudo -E ./run_rtvs.sh
```

