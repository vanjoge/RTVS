#! /bin/bash
echo "当前执行文件......$0"

##################################变量定义##################################
DOCKER_ATTACHMENT_NAME=${DOCKER_ATTACHMENT_NAME:-"attachment-1"}
DOCKER_ATTACHMENT_PATH=${DOCKER_ATTACHMENT_PATH:-"/etc/service/$DOCKER_ATTACHMENT_NAME"}
DOCKER_ATTACHMENT_IMAGE_NAME=${DOCKER_ATTACHMENT_IMAGE_NAME:-"vanjoge/attachment:1.3.7"}
DOCKER_ATTACHMENT_KafkaTopic=${DOCKER_ATTACHMENT_KafkaTopic:-"media-complete"}


#外网IP

#端口  

DOCKER_ATTACHMENT_PORT=${DOCKER_ATTACHMENT_PORT:-6030}
DOCKER_ATTACHMENT_HTTP_PORT=${DOCKER_ATTACHMENT_HTTP_PORT:-9082}

DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_ATTACHMENT_IP=${DOCKER_ATTACHMENT_IP:-"172.29.108.246"}

 
if [ ! -n "$LocWebFileUrl" ] ; then
    LocWebFileUrl="http://$IPADDRESS:$DOCKER_ATTACHMENT_HTTP_PORT/alarmfiles"
fi
 
function updateJson()
{
    val=`echo "$3"| sed 's:\/:\\\/:g'`
    echo "正在修改Json文件:$1,节点:$2,新值:$3"
    sed -i "s/\"$2\":.*$/\"$2\": \"$val\",/" $1
    unset val
}
function init_system_files_path()
{ 
    # 创建目录
    if [[ ! -d "/etc/service" ]]; then
        mkdir /etc/service
    fi
    if [[ ! -d $DOCKER_ATTACHMENT_PATH ]]; then
        mkdir $DOCKER_ATTACHMENT_PATH
    fi
    cd attachment
    # 复制AppConfig.json
    if [[ -f "./AppConfig.json" ]]; then
        echo "拷贝文件： ./AppConfig.json $DOCKER_ATTACHMENT_PATH/AppConfig.json"
        cp -f AppConfig.json $DOCKER_ATTACHMENT_PATH/AppConfig.json
    else
        echo "缺少./AppConfig.json文件...已退出安装!"
        exit
    fi
    cd ..
}
 
function docker_run(){
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json ListenPort $DOCKER_ATTACHMENT_PORT
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json LocWebFileUrl "$LocWebFileUrl"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json KafkaServer "$KafkaServer"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json KafkaTopic "$DOCKER_ATTACHMENT_KafkaTopic"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json AliOssEndpoint "$DOCKER_ATTACHMENT_AliOssEndpoint"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json AliOssAccessKeyId "$DOCKER_ATTACHMENT_AliOssAccessKeyId"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json AliOssAccessKeySecret "$DOCKER_ATTACHMENT_AliOssAccessKeySecret"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json AliOssBucketName "$DOCKER_ATTACHMENT_AliOssBucket"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json AliOssCallbackUrl "$DOCKER_ATTACHMENT_AliOssCallbackUrl"
    
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json FileServerUrl "$DOCKER_ATTACHMENT_FileServerUrl"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json UserToken "$DOCKER_ATTACHMENT_UserToken"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json ConnectionString "$DOCKER_ATTACHMENT_ConnectionString"
    updateJson $DOCKER_ATTACHMENT_PATH/AppConfig.json RedisConnectionString "$DOCKER_ATTACHMENT_RedisConnectionString"
    
    
    docker pull $DOCKER_ATTACHMENT_IMAGE_NAME
    #启动
    docker run  --name $DOCKER_ATTACHMENT_NAME --net $DOCKER_NETWORK --ip $DOCKER_ATTACHMENT_IP --restart always  --privileged=true \
    -v $DOCKER_ATTACHMENT_PATH/AppConfig.json:/app/AppConfig.json \
    -v $DOCKER_ATTACHMENT_PATH/media:/app/media  \
    -v $DOCKER_ATTACHMENT_PATH/logs:/app/logs  \
    -v $DOCKER_ATTACHMENT_PATH/avlogs:/app/avlogs  \
    -p $DOCKER_ATTACHMENT_HTTP_PORT:80 \
    -p $DOCKER_ATTACHMENT_PORT:$DOCKER_ATTACHMENT_PORT/tcp \
    -p $DOCKER_ATTACHMENT_PORT:$DOCKER_ATTACHMENT_PORT/udp \
    -d $DOCKER_ATTACHMENT_IMAGE_NAME
}
function main(){
    echo "依赖文件检查...."
    init_system_files_path
    
    #启动镜像
    docker_run
    
    echo "主动安全附件服务启动完成"
    echo ""
}
###################################脚本入口#######################################

    main 
