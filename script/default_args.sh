#! /bin/bash

##################################变量定义##################################

#DOCKERHUB
DOCKER_IMG_PREFIX=${DOCKER_IMG_PREFIX:-"docker.cnb.cool/rtvsmirror/"} #镜像前缀，可用来指定镜像服务器或代理地址，未指定时从dockerhub拉取

#证书

CV_PFX_PATH=${CV_PFX_PATH:-$CV_PXF_PATH} #兼容之前变量
CV_PFX_PWD=${CV_PFX_PWD:-$CV_PXF_PWD} #兼容之前变量
CV_PFX_PATH=${CV_PFX_PATH:-""} #PFX证书路径 1.3.8版本之后可不提供
CV_PFX_PWD=${CV_PFX_PWD:-""} #PFX证书密码
CV_PEM_PATH=${CV_PEM_PATH:-""} #PEM证书路径
CV_PEMKEY_PATH=${CV_PEMKEY_PATH:-""} #PEM证书私钥路径

#网络
RTVS_NETWORK_HOST=${RTVS_NETWORK_HOST:-"false"} #启用HOST模式，HOST模式下没有NAT转换，不会主动开放防火墙端口
DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"} #docker 自定义网络名称
DOCKER_NETWORK_IPS=${DOCKER_NETWORK_IPS:-"172.29.108"} #docker 自定义网络IP段
DOCKER_GATEWAY_HOST=${DOCKER_GATEWAY_HOST:-"$DOCKER_NETWORK_IPS.1"} #docker 自定义网络访问宿主IP

DOCKER_CVCLUSTER_IP=${DOCKER_CVCLUSTER_IP:-"$DOCKER_NETWORK_IPS.254"} #集群管理docker内部IP地址 非HOST模式下生效
DOCKER_CDVR_IP=${DOCKER_CDVR_IP:-"$DOCKER_NETWORK_IPS.250"} #云端录像docker内部IP地址 非HOST模式下生效
DOCKER_GW_IP=${DOCKER_GW_IP:-"$DOCKER_NETWORK_IPS.249"} #测试808网关docker内部IP地址 非HOST模式下生效
DOCKER_GB2JT_IP=${DOCKER_GB2JT_IP:-"$DOCKER_NETWORK_IPS.248"} #(已废弃)GB2JT docker内部IP地址 非HOST模式下生效
DOCKER_GBSIP_IP=${DOCKER_GBSIP_IP:-"$DOCKER_NETWORK_IPS.247"} #GBSIP docker内部IP地址 非HOST模式下生效
DOCKER_ATTACHMENT_IP=${DOCKER_ATTACHMENT_IP:-"$DOCKER_NETWORK_IPS.246"} #主动安全附件服务 docker内部IP地址 非HOST模式下生效
DOCKER_REDIS_IP=${DOCKER_REDIS_IP:-"$DOCKER_NETWORK_IPS.245"} #Redis docker内部IP地址
GRAFANA_DOCKER_IP=${GRAFANA_DOCKER_IP:-"$DOCKER_NETWORK_IPS.243"} #Grafana docker内部IP地址
TSDB_DOCKER_IP=${TSDB_DOCKER_IP:-"$DOCKER_NETWORK_IPS.242"} #TSDB docker内部IP地址
MYSQL_DOCKER_IP=${MYSQL_DOCKER_IP:-"$DOCKER_NETWORK_IPS.241"} #MYSQL docker内部IP地址
#WEBRTC_DOCKER_IP=${WEBRTC_DOCKER_IP:-"$DOCKER_NETWORK_IPS.240"}

#端口
MYSQL_DOCKER_PORT=${MYSQL_DOCKER_PORT:-3306} #MYSQL docker实例端口
GRAFANA_DOCKER_PORT=${GRAFANA_DOCKER_PORT:-33000} #Grafana docker实例端口
WEBRTC_DOCKER_API_PORT=${WEBRTC_DOCKER_API_PORT:-"13188"} #SFU端口 内部用 一般不用修改，host模式时被占用才需要修改

DOCKER_HTTP_PORT=${DOCKER_HTTP_PORT:-30888} #集群管理 HTTP端口
DOCKER_HTTPS_PORT=${DOCKER_HTTPS_PORT:-30443} #(已废弃)集群管理 HTTPS端口
DOCKER_WEBSOCKET_PORT=${DOCKER_WEBSOCKET_PORT:-17000} #集群管理 WS/WSS端口

DOCKER_GBSIP_PORT=${DOCKER_GBSIP_PORT:-5060} #GBSIP GB28181协议接入端口
DOCKER_GBSIP_HTTP_PORT=${DOCKER_GBSIP_HTTP_PORT:-9081} #GBSIP HTTP端口

DOCKER_808_PORT=${DOCKER_808_PORT:-9300} #808测试网关 808协议接入端口
DOCKER_808_HTTP_PORT=${DOCKER_808_HTTP_PORT:-9080} #808测试网关 WEB服务端口

DOCKER_SIP_PORT=${DOCKER_SIP_PORT:-5060} #(已废弃)GB2JT GB28181协议接入端口
DOCKER_RTP_PORT=${DOCKER_RTP_PORT:-30000} #(已废弃)GB2JT RTP流接入端口

DOCKER_ATTACHMENT_PORT=${DOCKER_ATTACHMENT_PORT:-6030} #主动安全附件服务 附件上报接入端口
DOCKER_ATTACHMENT_HTTP_PORT=${DOCKER_ATTACHMENT_HTTP_PORT:-9082} #主动安全附件服务 WEB服务端口

PORT_DEV_START=${PORT_DEV_START:-6001} #服务端口范围 从PORT_DEV_START开始找30个可用端口
PORT_DEV_END=${PORT_DEV_END:-65535} #服务端口范围 如果到PORT_DEV_END还未找到30个可用端口，会退出本次启动
Webrtc_Port_Start=${Webrtc_Port_Start:-14001} #webrtc连接端口范围
Webrtc_Port_End=${Webrtc_Port_End:-65535} #webrtc连接端口范围
PORT_DEV_BINDPORT_START=${PORT_DEV_BINDPORT_START:-0} #设备连接端口开始值 为0时受PORT_DEV_START控制；不为0时可单独设置

DOCKER_RTSP_PORT_RANGE_UDP=${DOCKER_RTSP_PORT_RANGE_UDP:-"14100-14200"} #RTSP通信端口范围

#其他
APIAuthorization=${APIAuthorization:-"12345678"} #API请求时添加的Authorization头
RTVS_UPDATECHECK_DOCKER=${RTVS_UPDATECHECK_DOCKER:-"true"} #是否启动容器前自动pull一次(更新)镜像
SwaggerUI=${SwaggerUI:-"true"} #是否开启SwaggerUI，当前SwaggerUI均需要登录才能访问，不会有未授权访问等安全扫描问题
VerifyHttpVideo=${VerifyHttpVideo:-"false"} #控制http-flv,http-fmp4是否验证时效口令

#客户端认证
RTVS_CLIENT_AUTH=${RTVS_CLIENT_AUTH:-"false"} #强制启用客户端认证
RTVS_TOKEN_TIMEOUT_SEC=${RTVS_TOKEN_TIMEOUT_SEC:-"300"} #Token最长过期时间
RTVS_CARSA_PEMKEY_PATH=${RTVS_CARSA_PEMKEY_PATH:-""} #客户端RSA认证证书私钥路径
RTVS_CARSA_TIMEOUT_SEC=${RTVS_CARSA_TIMEOUT_SEC:-"60"} #客户端RSA认证超时时间


#
DOCKER_CLUSTER_NAME=${DOCKER_CLUSTER_NAME:-"cvcluster-1"} #集群管理容器名称
DOCKER_CLUSTER_PATH=${DOCKER_CLUSTER_PATH:-"/etc/service/$DOCKER_CLUSTER_NAME"} #集群管理容器配置文件路径
DOCKER_CLUSTER_IMAGE_NAME=${DOCKER_CLUSTER_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}vanjoge/cvcluster:1.3.12"} #集群管理镜像名称和版本

DOCKER_GBSIP_NAME=${DOCKER_GBSIP_NAME:-"gbsip-1"} #GBSIP容器名称
DOCKER_GBSIP_PATH=${DOCKER_GBSIP_PATH:-"/etc/service/$DOCKER_GBSIP_NAME"} #GBSIP容器配置文件路径
DOCKER_GBSIP_IMAGE_NAME=${DOCKER_GBSIP_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}vanjoge/gbsip:latest"} #GBSIP镜像名称和版本
DOCKER_GBSIP_ENABLESIPLOG=${DOCKER_GBSIP_ENABLESIPLOG:-"true"} #是否启用SIP日志
DOCKER_GBSIP_ALIVETIMEOUTSEC=${DOCKER_GBSIP_ALIVETIMEOUTSEC:-180} #SIP信令超时时长
DOCKER_GBSIP_RTVSAPI=${DOCKER_GBSIP_RTVSAPI:-"http://$DOCKER_NETWORK_IPS.11/"} #GBSIP访问RTVSAPI地址


DOCKER_GB_SEND_PORT_MIN=${DOCKER_GB_SEND_PORT_MIN:-0} #GB级联本地端口最小值 0不限制
DOCKER_GB_SEND_PORT_MAX=${DOCKER_GB_SEND_PORT_MAX:-0} #GB级联本地端口最大值 0不限制

DOCKER_GW_NAME=${DOCKER_GW_NAME:-"tstgw808-1"} #808网关容器名称
DOCKER_GW_PATH=${DOCKER_GW_PATH:-"/etc/service/$DOCKER_GW_NAME"} #808网关容器配置文件路径
DOCKER_GW_IMAGE_NAME=${DOCKER_GW_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}vanjoge/gw808"} #808网关镜像名称和版本


DOCKER_REDIS_NAME=${DOCKER_REDIS_NAME:-"tstgw_redis"} #redis容器名称
DOCKER_REDIS_IMAGE_NAME=${DOCKER_REDIS_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}redis:4.0.10-alpine"} #redis镜像名称和版本

DOCKER_GB2JT_NAME=${DOCKER_GB2JT_NAME:-"gb2jt-1"} #(已废弃)gb2jt容器名称
DOCKER_GB2JT_PATH=${DOCKER_GB2JT_PATH:-"/etc/service/$DOCKER_GB2JT_NAME"} #(已废弃)gb2jt容器配置文件路径
DOCKER_GB2JT_IMAGE_NAME=${DOCKER_GB2JT_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}vanjoge/gb2jt:1.3.4"} #(已废弃)gb2jt镜像名称和版本
#0 UDP 1 TCP
GB28181_RTP_TYPE=${GB28181_RTP_TYPE:-"1"} #(已废弃)gb2jt的RTP用UDP还是TCP


DOCKER_ATTACHMENT_NAME=${DOCKER_ATTACHMENT_NAME:-"attachment-1"} #主动安全附件服务容器名称
DOCKER_ATTACHMENT_PATH=${DOCKER_ATTACHMENT_PATH:-"/etc/service/$DOCKER_ATTACHMENT_NAME"} #主动安全附件服务容器配置文件路径
DOCKER_ATTACHMENT_IMAGE_NAME=${DOCKER_ATTACHMENT_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}vanjoge/attachment:1.3.11"} #主动安全附件服务镜像名称和版本
DOCKER_ATTACHMENT_KafkaTopic=${DOCKER_ATTACHMENT_KafkaTopic:-"media-complete"} #主动安全附件服务KafkaTopic通知名称
#KafkaServer KafkaServer连接字符串

NGINX_DOCKER_PATH_TEMPLATE=${NGINX_DOCKER_PATH_TEMPLATE:-"/etc/service/nginx-rtmp-"} #nginx容器配置文件地址模板
NGINX_DOCKER_CONTAINER_NAME_TEMPLATE=${NGINX_DOCKER_CONTAINER_NAME_TEMPLATE:-"nginx-rtmp-"} #nginx容器名称模板
NGINX_DOCKER_IMAGE_NAME=${NGINX_DOCKER_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}vanjoge/nginx-rtmp:flvlive"} #nginx镜像名称和版本

MYSQL_DOCKER_PATH=${MYSQL_DOCKER_PATH:-"/etc/mysql"} #mysql容器配置文件地址
MYSQL_DOCKER_CONTAINER_NAME=${MYSQL_DOCKER_CONTAINER_NAME:-"mysql5.7"} #mysql容器名称
MYSQL_DOCKER_IMAGE_VERSION=${MYSQL_DOCKER_IMAGE_VERSION:-"5.7"} #mysql镜像版本
#MYSQL_DOCKER_IMAGE_NAME mysql镜像名称 不传入会自动配置

#传入MYSQL_Server_IP和MYSQL_Server_PORT有效值时不启动MYSQL实例
#仅传入MYSQL_Server_PORT表示映射出端口
#MYSQL_Server_IP    mysql服务器地址
#MYSQL_Server_PORT  mysql服务器端口

TSDB_DOCKER_CONTAINER_NAME=${TSDB_DOCKER_CONTAINER_NAME:-"influxdb"} #tsdb容器名称
TSDB_DOCKER_PATH=${TSDB_DOCKER_PATH:-"/etc/influxdb"} #tsdb容器配置文件地址
INFLUXDB_VERSION=${INFLUXDB_VERSION:-"1.7"} #tsdb镜像版本
INFLUXDB_IMAGE_NAME=${INFLUXDB_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}influxdb"} #tsdb镜像名称
#传入TSDB_Server_IP和TSDB_Server_PORT有效值时不启动influxdb实例
#仅传入TSDB_Server_PORT表示映射出端口
#TSDB_Server_IP
#TSDB_Server_PORT

WEBRTC_DOCKER_CONTAINER_NAME=${WEBRTC_DOCKER_CONTAINER_NAME:-"sfu-mediasoup"} #webrtc容器名称
WEBRTC_DOCKER_PATH=${WEBRTC_DOCKER_PATH:-"/etc/service/mediasoup"} #webrtc容器配置文件地址
WEBRTC_DOCKER_IMAGE_NAME=${WEBRTC_DOCKER_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}vanjoge/mediasoup-demo:v3"} #webrtc镜像名称和版本
WEBRTC_ONLY_TCP=${WEBRTC_ONLY_TCP:-"false"} #webrtc仅用TCP通信
WEBRTC_ONLY_UDP=${WEBRTC_ONLY_UDP:-"false"} #webrtc仅用UDP通信


GRAFANA_DOCKER_CONTAINER_NAME=${GRAFANA_DOCKER_CONTAINER_NAME:-"grafana"} #grafana容器名称
GRAFANA_DOCKER_PATH=${GRAFANA_DOCKER_PATH:-"/etc/grafana"} #grafana容器配置文件地址
GRAFANA_VERSION=${GRAFANA_VERSION:-"5.4.0"} #grafana镜像版本
RUN_GRAFANA=${RUN_GRAFANA:-"false"} #是否启用grafana



RTVSWEB_DOCKER_CONTAINER_NAME_TEMPLATE=${RTVSWEB_DOCKER_CONTAINER_NAME_TEMPLATE:-"rtvsweb-publish-"} #rtvsweb容器名称模板
RTVSWEB_DOCKER_PATH_TEMPLATE=${RTVSWEB_DOCKER_PATH_TEMPLATE:-"/etc/service/rtvs-"} #rtvsweb容器配置文件地址模板
RTVSWEB_DOCKER_IMAGE_NAME=${RTVSWEB_DOCKER_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}vanjoge/rtvs"} #rtvsweb镜像名称
RTVSWEB_VERSION=${RTVSWEB_VERSION:-"1.3.12"} #rtvsweb镜像版本
MatchSim12And20=${MatchSim12And20:-"true"} #是否自动视频12和20位SIM，为false时表示严格模式，12位和20位车机会认为是两个不同车机
QueryVideoListTimeOutSec=${QueryVideoListTimeOutSec:-"60"} #查询历史视频列表超时时长(秒)
DomainToIP=${DomainToIP:-"true"} #下发给设备服务器信息时，是否自动将域名转为IP下发


#CDVR
CDVR_ENABLE=${CDVR_ENABLE:-"false"} #是否启用云端录像
CDVR_DOCKER_PATH=${CDVR_DOCKER_PATH:-"/etc/service/rtvscdvr"} #云端录像容器配置文件地址
CDVR_PREFIX=${CDVR_PREFIX:-"ydr"} #云端录像文件名前缀
CDVR_DOCKER_IMAGE_NAME=${CDVR_DOCKER_IMAGE_NAME:-"${DOCKER_IMG_PREFIX}vanjoge/rtvscdvr"} #云端录像镜像名称
CDVR_VERSION=${CDVR_VERSION:-"1.3.12"} #云端录像镜像版本
#CDVR_MEMORY_LIMIT=${CDVR_MEMORY_LIMIT:-"8g"} #云端录像内存限制配置
CDVR_DOCKER_CONTAINER_NAME=${CDVR_DOCKER_CONTAINER_NAME:-"rtvscdvr"} #云端录像容器名称
CDVR_DOCKER_RECORD_PATH=${CDVR_DOCKER_RECORD_PATH:-"/etc/service/cdvr"} #云端录像存储位置
CDVR_DOCKER_HTTP_PORT=${CDVR_DOCKER_HTTP_PORT:-"30889"} #云端录像服务HTTP端口(用于直接API访问)
CDVR_KEEP_GB=${CDVR_KEEP_GB:-"3"} #云端录像磁盘最小保留空间大小(GB)




#CDN
RTVS_CDN_URL=${RTVS_CDN_URL:-"http://cdn.cvnavi.com:38220/api/RequestCdnNode"} #CDN API接口地址
RTVS_CDN_ID=${RTVS_CDN_ID:-""} #CDNID 由CDN分配
RTVS_CDN_AKEY=${RTVS_CDN_AKEY:-""} #CDNKEY 由CDN分配
RTVS_CDN_HOST=${RTVS_CDN_HOST:-"cdn.cvnavi.com"} #CDN域名
RTVS_CDN_PORT=${RTVS_CDN_PORT:-"38225"} #CDN端口
RTVS_CDN_TYPE=${RTVS_CDN_TYPE:-"0"} #CDN类型 0表示不使用CDN


#集群管理API地址
if [ ! -n "$ClusterServer" ]; then
    if [[ "$RTVS_NETWORK_HOST" == "true" ]]; then
        ClusterServer="http://127.0.0.1:$DOCKER_HTTP_PORT/Api"
    else
        ClusterServer="http://$DOCKER_CVCLUSTER_IP/Api"
    fi
fi
#webrtc容器IP
if [ ! -n "$WEBRTC_DOCKER_IP" ]; then
    if [[ "$RTVS_NETWORK_HOST" == "true" ]]; then
        WEBRTC_DOCKER_IP="127.0.0.1"
    else
        WEBRTC_DOCKER_IP="$DOCKER_NETWORK_IPS.240"
    fi
fi


#非x86_64启用第三方mysql镜像
if  [ ! -n "$MYSQL_DOCKER_IMAGE_NAME" ] ;then
    get_arch=`arch`
    if [[ $get_arch =~ "x86_64" ]];then
        echo "$get_arch"
        MYSQL_DOCKER_IMAGE_NAME="${DOCKER_IMG_PREFIX}mysql"
    else
        echo "$get_arch"
        MYSQL_DOCKER_IMAGE_NAME="${DOCKER_IMG_PREFIX}biarms/mysql"
        GRAFANA_VERSION="5.4.4"
    fi
fi

WEBRTC_RTP_URL=${WEBRTC_RTP_URL:-"rtp://$WEBRTC_DOCKER_IP"} #webrtc的rtp发送地址