#! /bin/bash


DOCKER_MediaSoup_CONTAINER_NAME="vanjoge/mediasoup-demo"


export DEBUG=${DEBUG:="mediasoup:INFO* *WARN* *ERROR*"}
export INTERACTIVE=${INTERACTIVE:="true"}
export HTTPS_CERT_FULLCHAIN=${HTTPS_CERT_FULLCHAIN:="/server/certs/fullchain.pem"}
export HTTPS_CERT_PRIVKEY=${HTTPS_CERT_PRIVKEY:="/server/certs/privkey.pem"}
export MEDIASOUP_LISTEN_IP=${MEDIASOUP_LISTEN_IP:="0.0.0.0"}


DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}

WEBRTC_DOCKER_CONTAINER_NAME=${WEBRTC_DOCKER_CONTAINER_NAME:-"sfu-mediasoup"}
WEBRTC_DOCKER_PATH=${WEBRTC_DOCKER_PATH:-"/etc/service/mediasoup"}
WEBRTC_DOCKER_IP=${WEBRTC_DOCKER_IP:-"172.29.108.240"}

cvconf_onlyTcp=${cvconf_onlyTcp:-"false"}
cvconf_onlyUdp=${cvconf_onlyUdp:-"false"}

#替换文件字符串
#参数1.文件 2.查找字符串 3.替换字符串
function config_replace(){
    `sed -i "s/$2/$3/g" $1`
}

#判断容器状态 参数值 容器名
#返回值 0 未启动 1 启动 2 没有此容器   （有些容器没有.State这个属性）
function docker_stat(){
    for i in [ `docker inspect --format='{{.State.Running}}' $1` ]; do
        if [[ "$i" == "true" ]]; then
            return 1
        elif [[ "$i" == "false" ]]; then
                return 0
        fi
    done
    return 2
}

#判断容器是否安装
#返回值 0 未安装 1 已安装
function docker_is_image_install(){
    for rep in `docker images $1 --format "{{.Repository}}"`; do
        return 1
    done    
    return 0
}

#判断容器是否在运行
#返回值 0 未运行 1 在运行
function docker_is_ps_running(){
    for ps_id in `docker ps -f name=$WEBRTC_DOCKER_CONTAINER_NAME --format "{{.ID}}"`; do
        return 1
    done
    return 0
}

#停止正在运行的容器
function docker_stop_ps(){
    #for ps_id in `docker ps -f name=$WEBRTC_DOCKER_CONTAINER_NAME --format "{{.ID}}"`; do
        echo "即将停止$WEBRTC_DOCKER_CONTAINER_NAME"
        docker stop $WEBRTC_DOCKER_CONTAINER_NAME
        docker rm $WEBRTC_DOCKER_CONTAINER_NAME  #rm容器       
    #done
}

#没有则安装镜像
function docker_mediasoup_checkAndInstall(){
    docker_is_image_install $DOCKER_MediaSoup_CONTAINER_NAME
    ret=$?
    if [[ ret -eq 0 ]]; then
        echo "MediaSoup 未安装，即将安装"$DOCKER_MediaSoup_CONTAINER_NAME
        docker pull $DOCKER_MediaSoup_CONTAINER_NAME 
    fi

    unset ret
}
#没有则运行镜像
function docker_mediasoup_checkAndRun(){
    #docker_is_ps_running
    docker_stat $WEBRTC_DOCKER_CONTAINER_NAME
    ret=$?
    if [[ ret -eq 1 ]]; then
        echo "已在运行"$WEBRTC_DOCKER_CONTAINER_NAME
        return
    fi
    
    if [[ ret -eq 0 ]]; then
        docker rm $WEBRTC_DOCKER_CONTAINER_NAME 
    fi
    

    echo "即将运行"$WEBRTC_DOCKER_CONTAINER_NAME
    docker run \
        --privileged=true \
        --restart always \
        --name=$WEBRTC_DOCKER_CONTAINER_NAME \
        -p ${PROTOO_LISTEN_PORT}:${PROTOO_LISTEN_PORT}/tcp \
        -p ${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}:${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}/udp \
        -p ${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}:${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}/tcp \
        -v $WEBRTC_DOCKER_PATH/config.js:/server/config.js \
        -v $WEBRTC_DOCKER_PATH/source/server.js:/server/server.js \
        -v $WEBRTC_DOCKER_PATH/source/lib/Room.js:/server/lib/Room.js \
        --net $DOCKER_NETWORK \
        --ip $WEBRTC_DOCKER_IP\
        --init \
        -e DEBUG \
        -e INTERACTIVE \
        -e DOMAIN \
        -e PROTOO_LISTEN_PORT \
        -e HTTPS_CERT_FULLCHAIN \
        -e HTTPS_CERT_PRIVKEY \
        -e MEDIASOUP_LISTEN_IP \
        -e MEDIASOUP_ANNOUNCED_IP \
        -e MEDIASOUP_MIN_PORT \
        -e MEDIASOUP_MAX_PORT \
        -e MEDIASOUP_USE_VALGRIND \
        -e MEDIASOUP_VALGRIND_OPTIONS \
        -e MEDIASOUP_WORKER_BIN \
        -it \
        -d \
        $DOCKER_MediaSoup_CONTAINER_NAME

}

function init_base(){
    # 创建总目录
    if [[ ! -d "/etc/service" ]]; then
        mkdir /etc/service
    fi
    # 创建mediasoup目录
    if [[ ! -d "$WEBRTC_DOCKER_PATH" ]]; then
        mkdir $WEBRTC_DOCKER_PATH
    fi
    # 创建代码目录
    if [[ ! -d "$WEBRTC_DOCKER_PATH/source" ]]; then
        mkdir $WEBRTC_DOCKER_PATH/source
    fi
    if [[ ! -d "$WEBRTC_DOCKER_PATH/source/lib" ]]; then
        mkdir $WEBRTC_DOCKER_PATH/source/lib
    fi
    cp -f config.js config.js.tmp
    #设置配置
    #ip地址
    config_replace config.js.tmp 1.2.3.4 $IPADDRESS
    #http端口
    config_replace config.js.tmp 9.9.9.9 $Webrtc_Port_Http
    #码流起始端口
    config_replace config.js.tmp 1.1.1.1 $Webrtc_Port_Start
    #码流结束端口
    config_replace config.js.tmp 2.2.2.2 $Webrtc_Port_End
    #域名
    config_replace config.js.tmp 3.3.3.3 $HTTP_DOMAIN
    
    config_replace config.js.tmp process.env.cvconf_onlyTcp $cvconf_onlyTcp
    
    config_replace config.js.tmp process.env.cvconf_onlyUdp $cvconf_onlyUdp
    
    #配置和源码是否更新,更新则停止容器进程
    update=0
    if [ ! -f "$WEBRTC_DOCKER_PATH/config.js" ]; then
        update=1
        cp config.js.tmp $WEBRTC_DOCKER_PATH/config.js
    else
        diff config.js.tmp $WEBRTC_DOCKER_PATH/config.js
        if [ $? -ne 0 ]; then
            update=1
            cp config.js.tmp $WEBRTC_DOCKER_PATH/config.js
        fi
    fi
    
    if [ ! -f "$WEBRTC_DOCKER_PATH/source/server.js" ]; then
        update=1
        cp server.js $WEBRTC_DOCKER_PATH/source/server.js
    else
        diff server.js $WEBRTC_DOCKER_PATH/source/server.js
        if [ $? -ne 0 ]; then
            update=1
            cp server.js $WEBRTC_DOCKER_PATH/source/server.js
        fi
    fi
    
    if [ ! -f "$WEBRTC_DOCKER_PATH/source/lib/Room.js" ]; then
        update=1
        cp Room.js $WEBRTC_DOCKER_PATH/source/lib/Room.js
    else
        diff Room.js $WEBRTC_DOCKER_PATH/source/lib/Room.js
        if [ $? -ne 0 ]; then
            update=1
            cp Room.js $WEBRTC_DOCKER_PATH/source/lib/Room.js
        fi
    fi
    if [[ $update -eq 1 ]]; then
        echo "MediaSoup需要更新"
        docker_stop_ps
    fi
    unset update
}

function main(){
    init_base
    docker_mediasoup_checkAndInstall
    docker_mediasoup_checkAndRun
}

function helpinfo(){
    echo "-i 127.0.0.1 外网地址 支持IP和域名 必须"
    echo "-d 域名 必须"
    echo "-n 40000 起始端口 必须"
    echo "-m 41000 结束端口 必须"
}
###################################脚本入口#######################################

echo "=================遍历输入参数:====start"

while getopts ":i:d:n:m:" opt
do
    case $opt in
        i)
            IPADDRESS=$OPTARG
        ;;
        d)
            HTTP_DOMAIN=$OPTARG
        ;;
        n)
            Webrtc_Port_Http=$OPTARG
            Webrtc_Port_Start=$((Webrtc_Port_Http+1))
        ;;
        m)
            Webrtc_Port_End=$OPTARG
        ;;
        ?)
            echo "未知参数"
            exit 1;;
    esac
done
echo "=================遍历输入参数:====end"

if  [ ! -n "$Webrtc_Port_Start" ] ;then
    echo "必须输入开始端口"
    helpinfo
elif [ ! -n "$Webrtc_Port_End" ] ; then
    echo "必须输入结束端口"
    helpinfo
elif [ ! -n "$IPADDRESS" ] ; then
    echo "必须输入IP地址"
    helpinfo
else
    export MEDIASOUP_MIN_PORT=${MEDIASOUP_MIN_PORT:="$Webrtc_Port_Start"}
    export MEDIASOUP_MAX_PORT=${MEDIASOUP_MAX_PORT:="$Webrtc_Port_End"}
    export PROTOO_LISTEN_PORT=${PROTOO_LISTEN_PORT:="$Webrtc_Port_Http"}
    export DOMAIN="$HTTP_DOMAIN"
    export MEDIASOUP_ANNOUNCED_IP="$IPADDRESS"
    main 
fi






















