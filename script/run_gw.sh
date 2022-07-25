#! /bin/bash
echo "当前执行文件......$0"

##################################变量定义##################################
DOCKER_GW_NAME=${DOCKER_GW_NAME:-"tstgw808-1"}
DOCKER_GW_PATH=${DOCKER_GW_PATH:-"/etc/service/$DOCKER_GW_NAME"}
DOCKER_GW_IMAGE_NAME=${DOCKER_GW_IMAGE_NAME:-"vanjoge/gw808"}

DOCKER_REDIS_NAME=${DOCKER_REDIS_NAME:-"tstgw_redis"}

DOCKER_REDIS_IMAGE_NAME=${DOCKER_REDIS_IMAGE_NAME:-"redis:4.0.10-alpine"}

#端口  
DOCKER_808_PORT=${DOCKER_808_PORT:-9300}
DOCKER_808_HTTP_PORT=${DOCKER_808_HTTP_PORT:-9080}

DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_GW_IP=${DOCKER_GW_IP:-"172.29.108.249"}
DOCKER_REDIS_IP=${DOCKER_REDIS_IP:-"172.29.108.245"}

  
function docker_run(){
    #启动redis
    docker_stat $DOCKER_REDIS_NAME
    ret=$?
    if [[ ret -eq 2 ]]; then
        echo "REDIS未安装，即将安装REDIS"
        docker run  --name $DOCKER_REDIS_NAME --net $DOCKER_NETWORK --ip $DOCKER_REDIS_IP --restart always  --privileged=true   -d $DOCKER_REDIS_IMAGE_NAME
        cd ..
    elif  [[ ret -eq 1 ]]; then
        echo "REDIS已启动"
    else
        echo "REDIS未启动，即将启动REDIS"
        docker start $DOCKER_REDIS_NAME
    fi
    
    docker rm -f $DOCKER_GW_NAME 2>/dev/null
    
    docker pull $DOCKER_GW_IMAGE_NAME
    #启动gw
    docker run  --name $DOCKER_GW_NAME --net $DOCKER_NETWORK --ip $DOCKER_GW_IP --restart always  --privileged=true  -p $DOCKER_808_PORT:9300 -p $DOCKER_808_HTTP_PORT:80 -d $DOCKER_GW_IMAGE_NAME
}
#判断容器状态 参数值 容器名
#返回值 0 未启动 1 启动 2 没有此容器
function docker_stat(){
    for i in [ `docker inspect --format='{{.State.Running}}' $1 2>/dev/null` ]; do
        if [[ "$i" == "true" ]]; then
            return 1
        elif [[ "$i" == "false" ]]; then
                return 0
        fi
    done
    return 2
}
function main(){
    
    #启动镜像
    docker_run
    
    echo "网关启动完成"
    echo ""
}
###################################脚本入口#######################################

    main 
