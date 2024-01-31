#! /bin/bash
echo "当前执行文件......$0"

source default_args.sh


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

    echo "清理CDVR"
    docker rm -f $CDVR_DOCKER_CONTAINER_NAME
    
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
 
