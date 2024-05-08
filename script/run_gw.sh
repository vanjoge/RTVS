#! /bin/bash
echo "当前执行文件......$0"

source default_args.sh
unalias cp

  
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
    if [[ ! -d $DOCKER_GW_PATH ]]; then
        mkdir $DOCKER_GW_PATH
    fi
    cd gw808
    # 复制SettingConfig.xml
    if [[ -f "./SettingConfig.xml" ]]; then
        echo "拷贝文件： ./SettingConfig.xml $DOCKER_GW_PATH/SettingConfig.xml"
        cp -f SettingConfig.xml $DOCKER_GW_PATH/SettingConfig.xml
    else
        echo "缺少./SettingConfig.xml文件...已退出安装!"
        exit
    fi
    
    cd ..
}
function docker_run(){
    
    updateXml $DOCKER_GW_PATH/SettingConfig.xml PortClient "$DOCKER_808_PORT"

    #启动redis
    docker_stat $DOCKER_REDIS_NAME
    ret=$?
    if [[ ret -eq 2 ]]; then
        echo "REDIS未安装，即将安装REDIS"
        docker run  --name $DOCKER_REDIS_NAME --net $DOCKER_NETWORK --ip $DOCKER_REDIS_IP --restart always  --privileged=true   -d $DOCKER_REDIS_IMAGE_NAME
    elif  [[ ret -eq 1 ]]; then
        echo "REDIS已启动"
    else
        echo "REDIS未启动，即将启动REDIS"
        docker start $DOCKER_REDIS_NAME
    fi
    
    docker rm -f $DOCKER_GW_NAME 2>/dev/null
    
    if [[ "$RTVS_UPDATECHECK_DOCKER" == "true" ]]; then
        docker pull $DOCKER_GW_IMAGE_NAME
    fi
    #启动gw
    if [[ "$RTVS_NETWORK_HOST" == "true" ]]; then
        docker run  --name $DOCKER_GW_NAME --net host --restart always  --privileged=true \
        --log-opt max-size=500m --log-opt max-file=3 \
        -v $DOCKER_GW_PATH:/MyData \
        -e MyDataPath=/MyData \
        -e ASPNETCORE_URLS="http://*:$DOCKER_808_HTTP_PORT" \
        -d $DOCKER_GW_IMAGE_NAME
    else
        docker run  --name $DOCKER_GW_NAME --net $DOCKER_NETWORK --ip $DOCKER_GW_IP --restart always  --privileged=true \
        --log-opt max-size=500m --log-opt max-file=3 \
        -p $DOCKER_808_PORT:9300 \
        -p $DOCKER_808_HTTP_PORT:80 \
        -d $DOCKER_GW_IMAGE_NAME
    fi
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

    init_system_files_path
    #启动镜像
    docker_run
    
    echo "808网关启动完成"
    echo ""
}
###################################脚本入口#######################################

    main 
