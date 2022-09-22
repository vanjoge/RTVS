#! /bin/bash
echo "当前执行文件......$0"

##################################变量定义##################################
DOCKER_GBSIP_NAME=${DOCKER_GBSIP_NAME:-"gbsip-1"}
DOCKER_GBSIP_PATH=${DOCKER_GBSIP_PATH:-"/etc/service/$DOCKER_GBSIP_NAME"}
DOCKER_GBSIP_IMAGE_NAME=${DOCKER_GBSIP_IMAGE_NAME:-"vanjoge/gbsip:latest"}


MYSQL_DOCKER_IP=${MYSQL_DOCKER_IP:-"172.29.108.241"}

#外网IP

#端口  

DOCKER_GBSIP_PORT=${DOCKER_GBSIP_PORT:-5060}
DOCKER_GBSIP_HTTP_PORT=${DOCKER_GBSIP_HTTP_PORT:-9081}

DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_GBSIP_IP=${DOCKER_GBSIP_IP:-"172.29.108.247"}


DOCKER_GBSIP_ENABLESIPLOG=${DOCKER_GBSIP_ENABLESIPLOG:-"true"}
DOCKER_GBSIP_ALIVETIMEOUTSEC=${DOCKER_GBSIP_ALIVETIMEOUTSEC:-180}
DOCKER_GBSIP_RTVSAPI=${DOCKER_GBSIP_RTVSAPI:-"http://172.29.108.11/"}
DOCKER_WEBSOCKET_PORT=${DOCKER_WEBSOCKET_PORT:-17000}
 
if [ ! -n "$BeianAddress" ] ; then
    BeianAddress=$IPADDRESS
fi
 
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
    if [[ ! -d $DOCKER_GBSIP_PATH ]]; then
        mkdir $DOCKER_GBSIP_PATH
    fi
    cd gb28181
    # 复制Setting.xml
    if [[ -f "./Setting.xml" ]]; then
        echo "拷贝文件： ./Setting.xml $DOCKER_GBSIP_PATH/Setting.xml"
        cp -f Setting.xml $DOCKER_GBSIP_PATH/Setting.xml
    else
        echo "缺少./Setting.xml文件...已退出安装!"
        exit
    fi
    # 复制siplog4.config
    if [[ -f "./siplog4.config" ]]; then
        echo "拷贝文件： ./siplog4.config $DOCKER_GBSIP_PATH/siplog4.config"
        cp -f siplog4.config $DOCKER_GBSIP_PATH/siplog4.config
    else
        echo "缺少./siplog4.config文件...已退出安装!"
        exit
    fi
    
    # 复制log4.config
    if [[ -f "./log4.config" ]]; then
        echo "拷贝一份日志配置文件： ./log4.config $DOCKER_GBSIP_PATH/log4.config"
        cp  -f ./log4.config $DOCKER_GBSIP_PATH/log4.config
    else
        echo "缺少./log4.config文件...已退出安装!"
        exit
    fi
    cd ..
}
 
function docker_run(){
    updateXml $DOCKER_GBSIP_PATH/Setting.xml EnableSipLog "$DOCKER_GBSIP_ENABLESIPLOG"
    updateXml $DOCKER_GBSIP_PATH/Setting.xml ServerIP "$IPADDRESS"
    updateXml $DOCKER_GBSIP_PATH/Setting.xml SipPort "$DOCKER_GBSIP_PORT"
    updateXml $DOCKER_GBSIP_PATH/Setting.xml RedisExchangeHosts "$RedisExchangeHosts"
    updateXml $DOCKER_GBSIP_PATH/Setting.xml KeepAliveTimeoutSec "$DOCKER_GBSIP_ALIVETIMEOUTSEC"
    updateXml $DOCKER_GBSIP_PATH/Setting.xml RTVSAPI "$DOCKER_GBSIP_RTVSAPI"
    updateXml $DOCKER_GBSIP_PATH/Setting.xml RTVSVideoServer "$BeianAddress"
    updateXml $DOCKER_GBSIP_PATH/Setting.xml RTVSVideoPort "$DOCKER_WEBSOCKET_PORT"
    updateXml $DOCKER_GBSIP_PATH/Setting.xml MysqlConnectionString "$MysqlConnectionString"
    
    
    docker pull $DOCKER_GBSIP_IMAGE_NAME
    #启动RTVS
    docker run  --name $DOCKER_GBSIP_NAME --net $DOCKER_NETWORK --ip $DOCKER_GBSIP_IP --restart always  --privileged=true  -v $DOCKER_GBSIP_PATH:/MyData  -e MyDataPath=/MyData -p $DOCKER_GBSIP_HTTP_PORT:80 -p $DOCKER_GBSIP_PORT:$DOCKER_GBSIP_PORT/tcp -p $DOCKER_GBSIP_PORT:$DOCKER_GBSIP_PORT/udp -d $DOCKER_GBSIP_IMAGE_NAME
}
function main(){
    echo "依耐文件检查...."
    init_system_files_path
    
    if  [  -n "$MYSQL_Server_IP" ] ;then
        MysqlConnectionString="Database=gbs;Data Source=$MYSQL_Server_IP;port=$MYSQL_Server_PORT;User Id=rtvsweb;Password=rtvs2018;charset=utf8;pooling=true"
    else
        MysqlConnectionString="Database=gbs;Data Source=$MYSQL_DOCKER_IP;port=3306;User Id=rtvsweb;Password=rtvs2018;charset=utf8;pooling=true"
    fi
    #启动镜像
    docker_run
    
    echo "GB28281服务启动完成"
    echo ""
}
###################################脚本入口#######################################

    main 
