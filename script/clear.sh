#! /bin/bash
echo "当前执行文件......$0"


##################################传入变量##################################
RTVSWEB_DOCKER_CONTAINER_NAME_TEMPLATE=${RTVSWEB_DOCKER_CONTAINER_NAME_TEMPLATE:-"rtvsweb-publish-"}
RTVSWEB_DOCKER_PATH_TEMPLATE=${RTVSWEB_DOCKER_PATH_TEMPLATE:-"/etc/service/rtvs-"}
NGINX_DOCKER_PATH_TEMPLATE=${NGINX_DOCKER_PATH_TEMPLATE:-"/etc/service/nginx-rtmp-"}
NGINX_DOCKER_CONTAINER_NAME_TEMPLATE=${NGINX_DOCKER_CONTAINER_NAME_TEMPLATE:-"nginx-rtmp-"}
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-"vanjoge/rtvs"}

MYSQL_DOCKER_CONTAINER_NAME=${MYSQL_DOCKER_CONTAINER_NAME:-"mysql5.7"}
MYSQL_DOCKER_PATH=${MYSQL_DOCKER_PATH:-"/etc/mysql"}
MYSQL_DOCKER_IP=${MYSQL_DOCKER_IP:-"172.29.108.241"}

TSDB_DOCKER_CONTAINER_NAME=${TSDB_DOCKER_CONTAINER_NAME:-"influxdb"}
TSDB_DOCKER_PATH=${TSDB_DOCKER_PATH:-"/etc/influxdb"}
TSDB_DOCKER_IP=${TSDB_DOCKER_IP:-"172.29.108.242"}

WEBRTC_DOCKER_CONTAINER_NAME=${WEBRTC_DOCKER_CONTAINER_NAME:-"sfu-mediasoup"}
WEBRTC_DOCKER_PATH=${WEBRTC_DOCKER_PATH:-"/etc/service/mediasoup"}
WEBRTC_DOCKER_IP=${WEBRTC_DOCKER_IP:-"172.29.108.240"}
WEBRTC_RTP_URL=${WEBRTC_RTP_URL:-"rtp://172.29.108.240"}


GRAFANA_DOCKER_CONTAINER_NAME=${GRAFANA_DOCKER_CONTAINER_NAME:-"grafana"}
GRAFANA_DOCKER_PATH=${GRAFANA_DOCKER_PATH:-"/etc/grafana"}


DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_NETWORK_IPS=${DOCKER_NETWORK_IPS:-"172.29.108"}
DOCKER_GATEWAY_HOST=${DOCKER_GATEWAY_HOST:-"172.29.108.1"}

DOCKER_GW_NAME=${DOCKER_GW_NAME:-"tstgw808-1"}
DOCKER_GW_PATH=${DOCKER_GW_PATH:-"/etc/service/$DOCKER_GW_NAME"}

DOCKER_ATTACHMENT_NAME=${DOCKER_ATTACHMENT_NAME:-"attachment-1"}
DOCKER_ATTACHMENT_PATH=${DOCKER_ATTACHMENT_PATH:-"/etc/service/$DOCKER_ATTACHMENT_NAME"}

DOCKER_REDIS_NAME=${DOCKER_REDIS_NAME:-"tstgw_redis"}

DOCKER_CLUSTER_NAME=${DOCKER_CLUSTER_NAME:-"cvcluster-1"}
DOCKER_CLUSTER_PATH=${DOCKER_CLUSTER_PATH:-"/etc/service/$DOCKER_CLUSTER_NAME"}


DOCKER_GB2JT_NAME=${DOCKER_GB2JT_NAME:-"gb2jt-1"}
DOCKER_GB2JT_PATH=${DOCKER_GB2JT_PATH:-"/etc/service/$DOCKER_GB2JT_NAME"}

DOCKER_GBSIP_NAME=${DOCKER_GBSIP_NAME:-"gbsip-1"}
DOCKER_GBSIP_PATH=${DOCKER_GBSIP_PATH:-"/etc/service/$DOCKER_GBSIP_NAME"}


function main(){
    #RTVS
    echo "清理RTVS"
    docker rm -f $(docker ps -a | grep $RTVSWEB_DOCKER_CONTAINER_NAME_TEMPLATE | awk '{print $1}')
    #nginx
    echo "清理nginx"
    docker rm -f $(docker ps -a | grep $NGINX_DOCKER_CONTAINER_NAME_TEMPLATE | awk '{print $1}')
    
    if [[ $RM_ALL != 0 ]]; then
        echo "清理sfu"
        docker rm -f $WEBRTC_DOCKER_CONTAINER_NAME
        rm -rf $WEBRTC_DOCKER_PATH
    fi
    
    
    echo "清理网关"
    docker rm -f $DOCKER_GW_NAME
    rm -rf $DOCKER_GW_PATH

    echo "清理主动安全附件服务"
    docker rm -f $DOCKER_ATTACHMENT_NAME
    
    echo "清理集群管理"
    docker rm -f $DOCKER_CLUSTER_NAME
    rm -rf $DOCKER_CLUSTER_PATH
    
    echo "清理28181"
    docker rm -f $DOCKER_GB2JT_NAME
    docker rm -f $DOCKER_GBSIP_NAME
    
    if [[ $RM_ALL == 1 ]]; then
        echo "清理redis"
        docker rm -f $DOCKER_REDIS_NAME
        echo "清理grafana"
        docker rm -f $GRAFANA_DOCKER_CONTAINER_NAME
        rm -rf $GRAFANA_DOCKER_PATH
        
        echo "清理influxdb"
        docker rm -f $TSDB_DOCKER_CONTAINER_NAME
        rm -rf $TSDB_DOCKER_PATH
        
        echo "清理mysql"
        docker rm -f $MYSQL_DOCKER_CONTAINER_NAME
        rm -rf $MYSQL_DOCKER_PATH

        echo "清理主动安全附件文件"
        rm -rf $DOCKER_ATTACHMENT_PATH
    fi
    
}
function helpinfo(){
    echo "help 待完善"
}
###################################脚本入口#######################################
RM_ALL=0
if [[ "$1" == "all" ]]; then
    RM_ALL=1
fi

main 
 
