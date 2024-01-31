#! /bin/bash
echo "当前执行文件......$0"

source default_args.sh

#判断容器是否安装
#返回值 0 未安装 1 已安装
function docker_is_image_install(){
    for rep in `docker images $1 --format "{{.Repository}}"`; do
        return 1
    done    
    return 0
}


function auto_pull_docker_image(){
    docker_is_image_install $1
    ret=$?
    if [[ ret -eq 0 ]]; then
        echo "未找到镜像 $1"
        docker pull $1 
    elif [[ $2 -eq 1 ]]; then
        docker pull $1 
    fi
}

function main(){
    
    if [[ "$RUN_GRAFANA" == "true" ]]; then
        auto_pull_docker_image grafana/grafana:$GRAFANA_VERSION $PL_BASE
    fi
    
    auto_pull_docker_image influxdb:$INFLUXDB_VERSION $PL_BASE

    auto_pull_docker_image $MYSQL_DOCKER_IMAGE_NAME:$MYSQL_DOCKER_IMAGE_VERSION $PL_BASE

    auto_pull_docker_image $DOCKER_REDIS_IMAGE_NAME $PL_BASE
    
    auto_pull_docker_image $DOCKER_GBSIP_IMAGE_NAME $PL_RTVS

    #auto_pull_docker_image $DOCKER_GB2JT_IMAGE_NAME $PL_RTVS

    auto_pull_docker_image $DOCKER_ATTACHMENT_IMAGE_NAME $PL_RTVS

    auto_pull_docker_image $DOCKER_CLUSTER_IMAGE_NAME $PL_RTVS

    auto_pull_docker_image $DOCKER_GW_IMAGE_NAME $PL_RTVS

    auto_pull_docker_image $RTVSWEB_DOCKER_IMAGE_NAME:$RTVSWEB_VERSION $PL_RTVS
    
    auto_pull_docker_image $NGINX_DOCKER_IMAGE_NAME $PL_RTVS

    auto_pull_docker_image $WEBRTC_DOCKER_IMAGE_NAME $PL_RTVS

    
    if [[ "$CDVR_ENABLE" == "true" ]]; then
        auto_pull_docker_image $CDVR_DOCKER_IMAGE_NAME:$CDVR_VERSION $PL_RTVS
    fi


}
###################################脚本入口#######################################
PL_BASE=0
PL_RTVS=0
if [[ "$1" == "all" ]]; then
    PL_BASE=1
    PL_RTVS=1
elif [[ "$RTVS_UPDATECHECK_DOCKER" == "true" ]]; then
    PL_RTVS=1
fi

main 