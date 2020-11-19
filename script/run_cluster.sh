#! /bin/bash
echo "当前执行文件......$0"

##################################变量定义##################################
DOCKER_CLUSTER_NAME=${DOCKER_CLUSTER_NAME:-"cvcluster-1"}
DOCKER_CLUSTER_PATH=${DOCKER_CLUSTER_PATH:-"/etc/service/$DOCKER_CLUSTER_NAME"}
DOCKER_CLUSTER_IMAGE_NAME=${DOCKER_CLUSTER_IMAGE_NAME:-"vanjoge/cvcluster:1.2.8"}

#证书
CV_PXF_PATH=${CV_PXF_PATH:-""}
CV_PXF_PWD=${CV_PXF_PWD:-""}

#外网IP

#端口  

DOCKER_HTTP_PORT=${DOCKER_HTTP_PORT:-30888}
DOCKER_HTTPS_PORT=${DOCKER_HTTPS_PORT:-30443}
DOCKER_WEBSOCKET_PORT=${DOCKER_WEBSOCKET_PORT:-17000}

DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_CVCLUSTER_IP=${DOCKER_CVCLUSTER_IP:-"172.29.108.254"}

 
 
function updateXml()
{
    val=`echo "$3"| sed 's:\/:\\\/:g'`
    if [[  $# -eq 4  ]]; then
        echo "正在修改XML文件:$1,节点:$2,新值:$3,原值:$4"
        #echo "sed -i 's/<$2>$4<\/$2>/<$2>$val<\/$2>/g' $1"
        sed -i "s/<$2>$4<\/$2>/<$2>$val<\/$2>/g" $1
    elif [[  $# -eq 3  ]]; then
        echo "正在修改XML文件:$1,节点:$2,新值:$3"
        #echo "sed -i 's/<$2>.*<\/$2>/<$2>$val<\/$2>/g' $1"
        sed -i "s/<$2>.*<\/$2>/<$2>$val<\/$2>/g" $1
    fi
    unset val
}
function init_system_files_path()
{ 
    # 创建目录
    if [[ ! -d "/etc/service" ]]; then
        mkdir /etc/service
    fi
    if [[ ! -d $DOCKER_CLUSTER_PATH ]]; then
        mkdir $DOCKER_CLUSTER_PATH
    fi
    cd clusterMyData
    # 复制ClusterConf.json
    if [[ -f "./ClusterConf.json" ]]; then
        echo "拷贝文件： ./ClusterConf.json $DOCKER_CLUSTER_PATH/ClusterConf.json"
        cp -f ClusterConf.json $DOCKER_CLUSTER_PATH/ClusterConf.json
    else
        echo "缺少./ClusterConf.json文件...已退出安装!"
        exit
    fi
    # 复制ClusterConfVer.json
    if [[ -f "./ClusterConfVer.json" ]]; then
        echo "拷贝文件： ./ClusterConfVer.json $DOCKER_CLUSTER_PATH/ClusterConfVer.json"
        cp -f ClusterConfVer.json $DOCKER_CLUSTER_PATH/ClusterConfVer.json
    else
        echo "缺少./ClusterConfVer.json文件...已退出安装!"
        exit
    fi
    # 复制ApiServer.xml
    if [[ -f "./ApiServer.xml" ]]; then
        echo "拷贝文件： ./ApiServer.xml $DOCKER_CLUSTER_PATH/ApiServer.xml"
        cp -f ApiServer.xml $DOCKER_CLUSTER_PATH/ApiServer.xml
    else
        echo "缺少./ApiServer.xml文件...已退出安装!"
        exit 1
    fi
    # 复制证书
    if [ -n "$CV_PXF_PATH" ]; then
        if [[ -f "$CV_PXF_PATH" ]]; then
            echo "拷贝证书： $CV_PXF_PATH $DOCKER_CLUSTER_PATH/certificate.pfx"
            cp -f $CV_PXF_PATH $DOCKER_CLUSTER_PATH/certificate.pfx
        else
            echo "缺少$CV_PXF_PATH文件...已退出安装!"
            exit 1
        fi
    else
        rm $DOCKER_CLUSTER_PATH/certificate.pfx
    fi
    
    # 复制log4.config
    if [[ -f "./log4.config" ]]; then
        echo "拷贝一份日志配置文件： ./log4.config $DOCKER_CLUSTER_PATH/log4.config"
        cp  -f ./log4.config $DOCKER_CLUSTER_PATH/log4.config
    else
        echo "缺少./log4.config文件...已退出安装!"
        exit
    fi
    cd ..
}
 
function docker_run(){
    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml X509FileName "/MyData/certificate.pfx"
    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml X509Password "$CV_PXF_PWD"
	
	
	docker pull $DOCKER_CLUSTER_IMAGE_NAME
    #启动RTVS
    docker run  --name $DOCKER_CLUSTER_NAME --net $DOCKER_NETWORK --ip $DOCKER_CVCLUSTER_IP --restart always  --privileged=true  -v $DOCKER_CLUSTER_PATH:/MyData  -e MyDataPath=/MyData -p $DOCKER_HTTP_PORT:80 -p $DOCKER_HTTPS_PORT:443  -p $DOCKER_WEBSOCKET_PORT:17000  -d $DOCKER_CLUSTER_IMAGE_NAME
}
function main(){
    echo "依耐文件检查...."
    init_system_files_path
    
    #启动镜像
    docker_run
    
    echo "集群管理启动完成"
    echo ""
}
###################################脚本入口#######################################

    main 
