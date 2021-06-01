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
DOCKER_HTTP_PORT=${DOCKER_HTTP_PORT:-9080}

DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_GW_IP=${DOCKER_GW_IP:-"172.29.108.249"}
DOCKER_REDIS_IP=${DOCKER_REDIS_IP:-"172.29.108.245"}

  
function docker_run(){
    #启动redis
    docker run  --name $DOCKER_REDIS_NAME --net $DOCKER_NETWORK --ip $DOCKER_REDIS_IP --restart always  --privileged=true   -d $DOCKER_REDIS_IMAGE_NAME
    
    docker rm -f $DOCKER_GW_NAME
	
	docker pull $DOCKER_GW_IMAGE_NAME
    #启动gw
    docker run  --name $DOCKER_GW_NAME --net $DOCKER_NETWORK --ip $DOCKER_GW_IP --restart always  --privileged=true  -p $DOCKER_808_PORT:9300 -p $DOCKER_HTTP_PORT:80 -d $DOCKER_GW_IMAGE_NAME
}
function main(){
	
    #启动镜像
    docker_run
    
	echo "网关启动完成"
	echo ""
}
###################################脚本入口#######################################

    main 
