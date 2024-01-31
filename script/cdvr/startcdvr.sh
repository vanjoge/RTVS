#! /bin/bash
echo "当前执行文件......$0"


source ../default_args.sh

RecordPath="/records"

###################################函数定义#######################################
 
function init_system_files_path()
{
    # 创建cdvr目录
    if [[ ! -d "/etc/service" ]]; then
        mkdir /etc/service
    fi

     
    # 创建cdvr目录
    if [[ ! -d $CDVR_DOCKER_PATH ]]; then
        mkdir $CDVR_DOCKER_PATH
    fi
    # 需要的时候复制服务配置文件
    if [[ -f "./MyData/SettingConfig.xml" ]]; then
        rm -f $CDVR_DOCKER_PATH/SettingConfig.xml 2>/dev/null
        echo "拷贝一份XML配置文件：cp ./MyData/SettingConfig.xml $CDVR_DOCKER_PATH/SettingConfig.xml"
        cp ./MyData/SettingConfig.xml $CDVR_DOCKER_PATH/SettingConfig.xml
        
    else
        echo "缺少./MyData/SettingConfig.xml文件...已退出安装!"
        exit 1
    fi
    # 复制log4.config（第一次做完全复制，若有变动需要手动修改）
    if [[ -f "./MyData/log4.config" ]]; then
        echo "拷贝一份日志配置文件： ./MyData/log4.config $CDVR_DOCKER_PATH/log4.config"
        cp  -f ./MyData/log4.config $CDVR_DOCKER_PATH/log4.config
    else
        echo "缺少./log4.config文件...已退出安装!"
        exit 1
    fi
    
    # 复制集群管理文件
    if [[ ! -d $CDVR_DOCKER_PATH/Config ]]; then
        mkdir $CDVR_DOCKER_PATH/Config
    fi
    if [[ -f "./MyData/Config/ClusterServer.json" ]]; then
        rm -f $CDVR_DOCKER_PATH/Config/ClusterServer.json 2>/dev/null
        echo "拷贝ClusterServer.json：./MyData/Config/ClusterServer.json $CDVR_DOCKER_PATH/Config/ClusterServer.json"
        cp ./MyData/Config/ClusterServer.json $CDVR_DOCKER_PATH/Config/ClusterServer.json
    else
        echo "缺少./Config/ClusterServer.json文件...已退出安装!"
        exit 1
    fi
} 

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

function update_cluster_conf()
{
    val=`echo "$2"| sed 's:\/:\\\/:g'`
    echo "正在修改ClusterServer配置文件:$1,Addr:$2"
    sed -i "s/\"Addr\":null/\"Addr\":\"$val\"/g" $1
    unset val
}
function update_config(){
    
    if [[ "$RTVS_NETWORK_HOST" == "true" ]]; then
        RTVSIP="127.0.0.1"
    fi


    #Rtmp地址修改
    updateXml $CDVR_DOCKER_PATH/SettingConfig.xml Server "$RTVSIP"
    updateXml $CDVR_DOCKER_PATH/SettingConfig.xml Port "$RTVS_WS_PORT"
    updateXml $CDVR_DOCKER_PATH/SettingConfig.xml RecordPath "$RecordPath"
    updateXml $CDVR_DOCKER_PATH/SettingConfig.xml Prefix "$CDVR_PREFIX"
    updateXml $CDVR_DOCKER_PATH/SettingConfig.xml SwaggerDoc $SwaggerUI
    updateXml $CDVR_DOCKER_PATH/SettingConfig.xml DiskReserveSpace $CDVR_KEEP_GB

    
    if  [ ! -n "$ClusterServer" ] ;then
        update_cluster_conf $CDVR_DOCKER_PATH/Config/ClusterServer.json "http://$DOCKER_GATEWAY_HOST:30888/Api"
    elif  [[ "$ClusterServer" == "null" ]]; then
        echo "ClusterServer无需修改"
    else
        update_cluster_conf $CDVR_DOCKER_PATH/Config/ClusterServer.json $ClusterServer
    fi
}
function docker_run(){
    
    if [[ "$RTVS_UPDATECHECK_DOCKER" == "true" ]]; then
        docker pull $CDVR_DOCKER_IMAGE_NAME:$CDVR_VERSION
    fi

    if [[ "$RTVS_NETWORK_HOST" == "true" ]]; then
    
        #启动CDVR
        if [ -n "$CDVR_MEMORY_LIMIT" ]; then
            docker run  \
            --name $CDVR_DOCKER_CONTAINER_NAME \
            --net host \
            --restart always  \
            --privileged=true  \
            -m $CDVR_MEMORY_LIMIT \
            -v $CDVR_DOCKER_PATH:/MyData \
            -v $CDVR_DOCKER_RECORD_PATH:$RecordPath \
            -e MyDataPath=/MyData \
            -e ASPNETCORE_URLS="http://*:$CDVR_DOCKER_HTTP_PORT" \
            -d $CDVR_DOCKER_IMAGE_NAME:$CDVR_VERSION
        else
            docker run  \
            --name $CDVR_DOCKER_CONTAINER_NAME \
            --net host \
            --restart always  \
            --privileged=true  \
            -v $CDVR_DOCKER_PATH:/MyData \
            -v $CDVR_DOCKER_RECORD_PATH:$RecordPath \
            -e MyDataPath=/MyData \
            -e ASPNETCORE_URLS="http://*:$CDVR_DOCKER_HTTP_PORT" \
            -d $CDVR_DOCKER_IMAGE_NAME:$CDVR_VERSION
        fi


    else
        
        #启动CDVR
        
        if [ -n "$CDVR_MEMORY_LIMIT" ]; then
            docker run  \
            --name $CDVR_DOCKER_CONTAINER_NAME \
            --net $DOCKER_NETWORK \
            --ip $LocIP\
            --restart always  \
            --privileged=true  \
            -m $CDVR_MEMORY_LIMIT \
            -v $CDVR_DOCKER_PATH:/MyData \
            -v $CDVR_DOCKER_RECORD_PATH:$RecordPath \
            -e MyDataPath=/MyData \
            -p $CDVR_DOCKER_HTTP_PORT:80 \
            -d $CDVR_DOCKER_IMAGE_NAME:$CDVR_VERSION
        else
            docker run  \
            --name $CDVR_DOCKER_CONTAINER_NAME \
            --net $DOCKER_NETWORK \
            --ip $LocIP\
            --restart always  \
            --privileged=true  \
            -v $CDVR_DOCKER_PATH:/MyData \
            -v $CDVR_DOCKER_RECORD_PATH:$RecordPath \
            -e MyDataPath=/MyData \
            -p $CDVR_DOCKER_HTTP_PORT:80 \
            -d $CDVR_DOCKER_IMAGE_NAME:$CDVR_VERSION
        fi

    fi
    
}
function main(){

    echo "依赖文件检查...."
    init_system_files_path

    
    #修改配置
    update_config
    
    
    #启动镜像
    docker_run
    
    echo "CDVR启动完成"
    echo ""
}
function helpinfo(){
    echo "help 待完善"
}
###################################脚本入口#######################################

echo "=================遍历输入参数:====start"

while getopts ":i:p:" opt
do
    case $opt in
        i)
            RTVSIP=$OPTARG
        ;;
        p)
            RTVS_WS_PORT=$OPTARG
        ;;
        ?)
            echo "未知参数"
            exit 1;;
    esac
done
echo "=================遍历输入参数:====end"


if  [ ! -n "$RTVSIP" ] ;then
    echo "必须传入RTVSIP"
    helpinfo
    
elif [ ! -n "$RTVS_WS_PORT" ] ; then
    echo "必须传入RTVS_WS_PORT"
    helpinfo
else
    main 
fi

