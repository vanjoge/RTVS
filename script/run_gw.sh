#! /bin/bash
echo "当前执行文件......$0"

##################################变量定义##################################
DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_NAME:-"tstgw808-1"}
DOCKER_CONTAINER_PATH=${DOCKER_CONTAINER_PATH:-"/etc/service/$DOCKER_CONTAINER_NAME"}
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-"vanjoge/gw808"}

DOCKER_REDIS_NAME=${DOCKER_REDIS_NAME:-"tstgw_redis"}

DOCKER_REDIS_IMAGE_NAME=${DOCKER_REDIS_IMAGE_NAME:-"redis:4.0.10-alpine"}

#端口  
DOCKER_808_PORT=${DOCKER_808_PORT:-9300}

DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_GW_IP=${DOCKER_GW_IP:-"172.29.108.249"}
DOCKER_REDIS_IP=${DOCKER_REDIS_IP:-"172.29.108.245"}

  
function docker_run(){
    #启动redis
    docker run  --name $DOCKER_REDIS_NAME --net $DOCKER_NETWORK --ip $DOCKER_REDIS_IP --restart always  --privileged=true   -d $DOCKER_REDIS_IMAGE_NAME
    
    docker rm -f $DOCKER_CONTAINER_NAME
    #启动gw
    docker run  --name $DOCKER_CONTAINER_NAME --net $DOCKER_NETWORK --ip $DOCKER_GW_IP --restart always  --privileged=true  -p $DOCKER_808_PORT:9300 -d $DOCKER_IMAGE_NAME
}
function main(){
	
    #启动镜像
    docker_run
    
}
###################################脚本入口#######################################

    main 
