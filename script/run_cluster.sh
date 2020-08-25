#! /bin/bash
echo "当前执行文件......$0"

##################################变量定义##################################
DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_NAME:-"cvcluster-1"}
DOCKER_CONTAINER_PATH=${DOCKER_CONTAINER_PATH:-"/etc/service/$DOCKER_CONTAINER_NAME"}
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-"vanjoge/rtvs:1.0.0"}
#外网IP

#端口  

DOCKER_HTTP_PORT=${DOCKER_HTTP_PORT:-30888}
DOCKER_HTTPS_PORT=${DOCKER_HTTPS_PORT:-30443}
DOCKER_WEBSOCKET_PORT=${DOCKER_WEBSOCKET_PORT:-17000}

DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_CVCLUSTER_IP=${DOCKER_CVCLUSTER_IP:-"172.29.108.254"}

 
function init_system_files_path()
{ 
    # 创建目录
    if [[ ! -d "/etc/service" ]]; then
        mkdir /etc/service
    fi
    if [[ ! -d $DOCKER_CONTAINER_PATH ]]; then
        mkdir $DOCKER_CONTAINER_PATH
    fi
	cd clusterMyData
    # 复制ClusterConf.json
    if [[ -f "./ClusterConf.json" ]]; then
        echo "拷贝一份日志配置文件： ./ClusterConf.json $DOCKER_CONTAINER_PATH/ClusterConf.json"
        cp -f ClusterConf.json $DOCKER_CONTAINER_PATH/ClusterConf.json
    else
        echo "缺少./ClusterConf.json文件...已退出安装!"
        exit
    fi
    # 复制ClusterConfVer.json
    if [[ -f "./ClusterConfVer.json" ]]; then
        echo "拷贝一份日志配置文件： ./ClusterConfVer.json $DOCKER_CONTAINER_PATH/ClusterConfVer.json"
        cp -f ClusterConfVer.json $DOCKER_CONTAINER_PATH/ClusterConfVer.json
    else
        echo "缺少./ClusterConfVer.json文件...已退出安装!"
        exit
    fi
    # 复制log4.config
    if [[ -f "./log4.config" ]]; then
        echo "拷贝一份日志配置文件： ./log4.config $DOCKER_CONTAINER_PATH/log4.config"
        cp  -f ./log4.config $DOCKER_CONTAINER_PATH/log4.config
    else
        echo "缺少./log4.config文件...已退出安装!"
        exit
    fi
    cd ..
}
 
function docker_run(){
    #启动RTVS
    docker run  --name $DOCKER_CONTAINER_NAME --net $DOCKER_NETWORK --ip $DOCKER_CVCLUSTER_IP --restart always  --privileged=true  -v $DOCKER_CONTAINER_PATH:/MyData  -e MyDataPath=/MyData -p $DOCKER_HTTP_PORT:80 -p $DOCKER_HTTPS_PORT:443  -p $DOCKER_WEBSOCKET_PORT:17000  -d DOCKER_IMAGE_NAME
}
function main(){
    echo "依耐文件检查...."
    init_system_files_path
	
    #启动镜像
    docker_run
    
}
###################################脚本入口#######################################

    main 
