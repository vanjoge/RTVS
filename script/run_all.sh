#! /bin/bash

#DOCKER_HTTP_PORT HTTP映射端口 默认30888
export DOCKER_HTTP_PORT=30888
#DOCKER_WEBSOCKET_PORT 客户端连接端口 默认17000
export DOCKER_WEBSOCKET_PORT=17000
#服务端口范围(在这个范围找30个可用的端口)
export PORT_DEV_START=6001
export PORT_DEV_END=65535
#webrtc连接端口范围(此范围找CPU核心数+2个端口)
export Webrtc_Port_Start=14001
export Webrtc_Port_End=65535
#808测试网关连接端口
export DOCKER_808_PORT=9300


#设置服务器IP地址或域名(内网测试无需映射端口 外网请映射端口)
#此配置是RTVS下发给设备的连接地址和客户端连接服务器的地址，请注意公网时的端口映射
export IPADDRESS=(Your IP or domain)
#设置网关接口地址
export GatewayBaseAPI=http://172.29.108.249/api/
#设置redis连接字符串
export RedisExchangeHosts=172.29.108.245:6379,connectTimeout=20000,syncTimeout=20000,responseTimeout=20000



./run_cluster.sh

./run_gw.sh

./run_rtvs.sh