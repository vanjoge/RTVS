#! /bin/bash
echo "当前执行文件......$0"


##################################传入变量##################################
RTVSWEB_DOCKER_CONTAINER_NAME_TEMPLATE=${RTVSWEB_DOCKER_CONTAINER_NAME_TEMPLATE:-"rtvsweb-publish-"}
RTVSWEB_DOCKER_PATH_TEMPLATE=${RTVSWEB_DOCKER_PATH_TEMPLATE:-"/etc/service/rtvs-"}
NGINX_DOCKER_PATH_TEMPLATE=${NGINX_DOCKER_PATH_TEMPLATE:-"/etc/service/nginx-rtmp-"}
NGINX_DOCKER_CONTAINER_NAME_TEMPLATE=${NGINX_DOCKER_CONTAINER_NAME_TEMPLATE:-"nginx-rtmp-"}
RTVSWEB_DOCKER_IMAGE_NAME=${RTVSWEB_DOCKER_IMAGE_NAME:-"vanjoge/rtvs"}
NGINX_DOCKER_IMAGE_NAME=${NGINX_DOCKER_IMAGE_NAME:-"vanjoge/nginx-rtmp:flvlive"}

MYSQL_DOCKER_CONTAINER_NAME=${MYSQL_DOCKER_CONTAINER_NAME:-"mysql5.7"}
MYSQL_DOCKER_PATH=${MYSQL_DOCKER_PATH:-"/etc/mysql"}
MYSQL_DOCKER_IP=${MYSQL_DOCKER_IP:-"172.29.108.241"}
#传入有效值时不启动MYSQL实例
#MYSQL_Server_IP
#MYSQL_Server_PORT

TSDB_DOCKER_CONTAINER_NAME=${TSDB_DOCKER_CONTAINER_NAME:-"influxdb"}
TSDB_DOCKER_PATH=${TSDB_DOCKER_PATH:-"/etc/influxdb"}
TSDB_DOCKER_IP=${TSDB_DOCKER_IP:-"172.29.108.242"}
#传入有效值时不启动influxdb实例
#TSDB_Server_IP
#TSDB_Server_PORT

WEBRTC_DOCKER_CONTAINER_NAME=${WEBRTC_DOCKER_CONTAINER_NAME:-"sfu-mediasoup"}
WEBRTC_DOCKER_PATH=${WEBRTC_DOCKER_PATH:-"/etc/service/mediasoup"}
WEBRTC_DOCKER_IP=${WEBRTC_DOCKER_IP:-"172.29.108.240"}
WEBRTC_RTP_URL=${WEBRTC_RTP_URL:-"rtp://172.29.108.240"}


GRAFANA_DOCKER_CONTAINER_NAME=${GRAFANA_DOCKER_CONTAINER_NAME:-"grafana"}
GRAFANA_DOCKER_PATH=${GRAFANA_DOCKER_PATH:-"/etc/grafana"}
RUN_GRAFANA=${RUN_GRAFANA:-"false"}


DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_NETWORK_IPS=${DOCKER_NETWORK_IPS:-"172.29.108"}
DOCKER_GATEWAY_HOST=${DOCKER_GATEWAY_HOST:-"172.29.108.1"}


#证书
CV_PFX_PATH=${CV_PFX_PATH:-$CV_PXF_PATH}
CV_PFX_PWD=${CV_PFX_PWD:-$CV_PXF_PWD}
CV_PFX_PATH=${CV_PFX_PATH:-""}
CV_PFX_PWD=${CV_PFX_PWD:-""}
CV_PEM_PATH=${CV_PEM_PATH:-""}
CV_PEMKEY_PATH=${CV_PEMKEY_PATH:-""}

#外网IP

#端口  
PORT_DEV_START=${PORT_DEV_START:-6001}
PORT_DEV_END=${PORT_DEV_END:-65535}
Webrtc_Port_Start=${Webrtc_Port_Start:-14001}
Webrtc_Port_End=${Webrtc_Port_End:-65535}
PORT_DEV_BINDPORT_START=${PORT_DEV_BINDPORT_START:-0}

ClusterServer=${ClusterServer:-"http://172.29.108.254/Api"}
MatchSim12And20=${MatchSim12And20:-"true"}
QueryVideoListTimeOutSec=${QueryVideoListTimeOutSec:-"60"}
DomainToIP=${DomainToIP:-"true"}


#CDN
RTVS_CDN_HOST=${RTVS_CDN_HOST:-"cdn.cvnavi.com"}
RTVS_CDN_PORT=${RTVS_CDN_PORT:-"38225"}
RTVS_CDN_ID=${RTVS_CDN_ID:-""}
RTVS_CDN_AKEY=${RTVS_CDN_AKEY:-""}
RTVS_CDN_TYPE=${RTVS_CDN_TYPE:-"0"}


##################################临时变量定义##################################
DOCKER_RUN_ID=0
DOCKER_RTVSWEB_CONTAINER_NAME=$RTVSWEB_DOCKER_CONTAINER_NAME_TEMPLATE"1"
DOCKER_RTVSWEB_PATH=$RTVSWEB_DOCKER_PATH_TEMPLATE"1"
DOCKER_NGINX_PATH=$NGINX_DOCKER_PATH_TEMPLATE"1"
DOCKER_NGINX_CONTAINER_NAME=$NGINX_DOCKER_CONTAINER_NAME_TEMPLATE"1";
DOCKER_RTVSWEB_VERSION="1.3.7"

DOCKER_RTVS_IP=11
DOCKER_RTMP_IP=12
DOCKER_HTTP_PORT=17000
DOCKER_HTTPS_PORT=17001
DOCKER_RTMP_PORT=17002
DOCKER_RTMP_STATE_PORT=17003
DOCKER_GOV_PORT=17004
DOCKER_OCX_PORT=17005
DOCKER_WS_PORT=17006
DOCKER_FMP4_PORT=17007
DOCKER_WSS_PORT=17008
DOCKER_DEV_PORT1=17010
DOCKER_DEV_PORT2=17011
DOCKER_DEV_PORT3=17012
DOCKER_DEV_PORT4=17013
DOCKER_DEV_PORT5=17014
DOCKER_DEV_PORT6=17015
DOCKER_DEV_PORT7=17016
DOCKER_DEV_PORT8=17017
DOCKER_DEV_PORT9=17018
DOCKER_DEV_PORT10=17019
DOCKER_DEV_PORT11=17020
DOCKER_DEV_PORT12=17021
DOCKER_DEV_PORT13=17022
DOCKER_DEV_PORT14=17023
DOCKER_DEV_PORT15=17024
DOCKER_DEV_PORT16=17025
DOCKER_DEV_PORT17=17026
DOCKER_DEV_PORT18=17027
DOCKER_DEV_PORT19=17028
DOCKER_DEV_PORT20=17029


###################################函数定义#######################################

function init_system_files_path_base()
{
    # 创建rtvs目录
    if [[ ! -d "/etc/service" ]]; then
        mkdir /etc/service
    fi
    # 创建mysql映射目录
    if [[ ! -d "$MYSQL_DOCKER_PATH" ]]; then
        mkdir $MYSQL_DOCKER_PATH
    fi
    if [[ ! -d "$MYSQL_DOCKER_PATH/conf.d" ]]; then
        mkdir $MYSQL_DOCKER_PATH/conf.d
    fi
    if [[ ! -d "$MYSQL_DOCKER_PATH/logs" ]]; then
        mkdir $MYSQL_DOCKER_PATH/logs
    fi
    if [[ ! -d "$MYSQL_DOCKER_PATH/data" ]]; then
        mkdir $MYSQL_DOCKER_PATH/data
    fi
    if [[ ! -d "$MYSQL_DOCKER_PATH/scripts" ]]; then
        mkdir $MYSQL_DOCKER_PATH/scripts
    fi
    # 创建$TSDB_DOCKER_PATH目录
    if [[ ! -d "$TSDB_DOCKER_PATH" ]]; then
        mkdir $TSDB_DOCKER_PATH
    fi
    if [[ ! -d "$TSDB_DOCKER_PATH/scripts" ]]; then
        mkdir $TSDB_DOCKER_PATH/scripts
    fi
    # 创建grafana目录
    if [[ ! -d "$GRAFANA_DOCKER_PATH" ]]; then
        mkdir $GRAFANA_DOCKER_PATH
    fi
    if [[ ! -d "$GRAFANA_DOCKER_PATH/conf" ]]; then
        mkdir $GRAFANA_DOCKER_PATH/conf
    fi
}
function init_system_files_path()
{

    DOCKER_RTVSWEB_PATH=$RTVSWEB_DOCKER_PATH_TEMPLATE$DOCKER_RUN_ID
    DOCKER_NGINX_PATH=$NGINX_DOCKER_PATH_TEMPLATE$DOCKER_RUN_ID
    # 创建nginx目录
    if [[ ! -d $DOCKER_NGINX_PATH ]]; then
        mkdir $DOCKER_NGINX_PATH
    fi
    
    
    # 复制nginx证书
    if [[ ! -d $DOCKER_NGINX_PATH/cert ]]; then
        mkdir $DOCKER_NGINX_PATH/cert
    fi
    if [ -n "$CV_PEM_PATH" ]; then
        if [[ -f "$CV_PEM_PATH" ]]; then
            echo "拷贝证书文件： $CV_PEM_PATH $DOCKER_NGINX_PATH/cert/certificate.crt"
            cp -f $CV_PEM_PATH $DOCKER_NGINX_PATH/cert/certificate.crt
        else
            echo "缺少$CV_PEM_PATH文件...已退出安装!"
            exit 1
        fi
        
        if [[ -f "$CV_PEMKEY_PATH" ]]; then
            echo "拷贝证书私钥： $CV_PEMKEY_PATH $DOCKER_NGINX_PATH/cert/privkey.pem"
            cp -f $CV_PEMKEY_PATH $DOCKER_NGINX_PATH/cert/privkey.pem
        else
            echo "缺少$CV_PEMKEY_PATH文件...已退出安装!"
            exit 1
        fi
        # 复制nginx.conf文件
        if [[ -f "./nginx/nginx.conf" ]]; then
            echo "拷贝一份nginx.conf：cp ./nginx/nginx.conf $DOCKER_NGINX_PATH/nginx.conf"
            cp ./nginx/nginx.conf $DOCKER_NGINX_PATH/nginx.conf
        else
            echo "缺少./nginx/nginx.conf文件...已退出安装!"
            exit 1
        fi
    else
        rm $DOCKER_NGINX_PATH/cert/certificate.crt 2>/dev/null
        rm $DOCKER_NGINX_PATH/cert/privkey.pem 2>/dev/null
        # 复制未加密nginx.conf文件
        if [[ -f "./nginx/nginx_nowss.conf" ]]; then
            echo "拷贝一份nginx_nowss.conf：cp ./nginx/nginx_nowss.conf $DOCKER_NGINX_PATH/nginx.conf"
            cp ./nginx/nginx_nowss.conf $DOCKER_NGINX_PATH/nginx.conf
        else
            echo "缺少./nginx/nginx_nowss.conf文件...已退出安装!"
            exit 1
        fi
    fi
    
    
    # 创建rtvs目录
    if [[ ! -d $DOCKER_RTVSWEB_PATH ]]; then
        mkdir $DOCKER_RTVSWEB_PATH
    fi
    # 复制程序指定的版本VersionConfig.xml
    if [[ -f "./rtvsMyData/VersionConfig.xml" ]]; then
        rm -f $DOCKER_RTVSWEB_PATH/VersionConfig.xml 2>/dev/null
        echo "拷贝一份XML配置文件：cp ./rtvsMyData/VersionConfig.xml $DOCKER_RTVSWEB_PATH/VersionConfig.xml"
        cp ./rtvsMyData/VersionConfig.xml $DOCKER_RTVSWEB_PATH/VersionConfig.xml
    else
        echo "缺少./rtvsMyData/VersionConfig.xml文件...已退出安装!"
        exit 1
    fi
    # 需要的时候复制服务配置文件
    if [[ -f "./rtvsMyData/SettingConfig.xml" ]]; then
        rm -f $DOCKER_RTVSWEB_PATH/SettingConfig.xml 2>/dev/null
        echo "拷贝一份XML配置文件：cp ./rtvsMyData/SettingConfig.xml $DOCKER_RTVSWEB_PATH/SettingConfig.xml"
        cp ./rtvsMyData/SettingConfig.xml $DOCKER_RTVSWEB_PATH/SettingConfig.xml
        
    else
        echo "缺少./rtvsMyData/SettingConfig.xml文件...已退出安装!"
        exit 1
    fi
    # 复制log4.config（第一次做完全复制，若有变动需要手动修改）
    if [[ -f "./rtvsMyData/log4.config" ]]; then
        echo "拷贝一份日志配置文件： ./rtvsMyData/log4.config $DOCKER_RTVSWEB_PATH/log4.config"
        cp  -f ./rtvsMyData/log4.config $DOCKER_RTVSWEB_PATH/log4.config
    else
        echo "缺少./log4.config文件...已退出安装!"
        exit 1
    fi
    
    # 复制证书
    if [ -n "$CV_PFX_PATH" ]; then
        if [[ -f "$CV_PFX_PATH" ]]; then
            echo "拷贝证书文件： $CV_PFX_PATH $DOCKER_RTVSWEB_PATH/certificate.pfx"
            cp -f $CV_PFX_PATH $DOCKER_RTVSWEB_PATH/certificate.pfx
        else
            echo "缺少$CV_PFX_PATH文件...已退出安装!"
            exit 1
        fi
    else
        rm $DOCKER_RTVSWEB_PATH/certificate.pfx 2>/dev/null
    fi
    
    # 复制集群管理文件
    if [[ ! -d $DOCKER_RTVSWEB_PATH/Config ]]; then
        mkdir $DOCKER_RTVSWEB_PATH/Config
    fi
    if [[ -f "./rtvsMyData/Config/ClusterServer.json" ]]; then
        rm -f $DOCKER_RTVSWEB_PATH/Config/ClusterServer.json 2>/dev/null
        echo "拷贝ClusterServer.json：./rtvsMyData/Config/ClusterServer.json $DOCKER_RTVSWEB_PATH/Config/ClusterServer.json"
        cp ./rtvsMyData/Config/ClusterServer.json $DOCKER_RTVSWEB_PATH/Config/ClusterServer.json
    else
        echo "缺少./Config/ClusterServer.json文件...已退出安装!"
        exit 1
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
#设置可用的RTVS容器名称 会设置DOCKER_RTVSWEB_CONTAINER_NAME变量
#返回值 RTVS容器ID 从1开始 返回0表示无效
function docker_set_DOCKER_RTVSWEB_CONTAINER_NAME(){
    DOCKER_RUN_ID=1;
    while [ $DOCKER_RUN_ID -lt 20 ]
    do
        DOCKER_RTVSWEB_CONTAINER_NAME=$RTVSWEB_DOCKER_CONTAINER_NAME_TEMPLATE$DOCKER_RUN_ID
        docker_stat $DOCKER_RTVSWEB_CONTAINER_NAME
        ret=$?
        if [[ ret -eq 0 ]]; then
            echo "$DOCKER_RTVSWEB_CONTAINER_NAME应用服务容器已停止，即将删除容器"
            docker rm $DOCKER_RTVSWEB_CONTAINER_NAME 2>/dev/null
            echo "$DOCKER_RTVSWEB_CONTAINER_NAME可用"
            return $DOCKER_RUN_ID;
        elif  [[ ret -eq 2 ]]; then
            echo "$DOCKER_RTVSWEB_CONTAINER_NAME可用"
            return $DOCKER_RUN_ID;
        else
            echo "$DOCKER_RTVSWEB_CONTAINER_NAME被占用"
        fi
        unset ret
        let "DOCKER_RUN_ID++"
        
    done
        
    return 0
}


function docker_base_install()
{
    #非x86_64启用第三方mysql镜像
    if  [ ! -n "$MYSQL_DOCKER_IMAGE_NAME" ] ;then
        get_arch=`arch`

        if [[ $get_arch =~ "x86_64" ]];then
            echo "$get_arch"
        else
            echo "$get_arch"
            export MYSQL_DOCKER_IMAGE_NAME="biarms/mysql"
            export GRAFANA_VERSION="5.4.4"
        fi
    fi

    init_system_files_path_base
    
    if  [  -n "$MYSQL_Server_IP" ] ;then
        MysqlConnectionString="Database=filecache;Data Source=$MYSQL_Server_IP;port=$MYSQL_Server_PORT;User Id=rtvsweb;Password=rtvs2018;charset=utf8;pooling=true"
    else
        #Mysql安装检查
        docker_mysql_checkAndInstall
        MysqlConnectionString="Database=filecache;Data Source=$MYSQL_DOCKER_IP;port=3306;User Id=rtvsweb;Password=rtvs2018;charset=utf8;pooling=true"
    fi
    
    if  [  -n "$TSDB_Server_IP" ] ;then
        InfluxdbBaseUrl="http://$TSDB_Server_IP:$TSDB_Server_PORT"
    else
        #influxdb安装检查
        docker_influxdb_checkAndInstall
        InfluxdbBaseUrl="http://$TSDB_DOCKER_IP:8086"
    fi
    if [[ "$RUN_GRAFANA" == "true" ]]; then
        #grafana安装检查
        docker_grafana_checkAndInstall
    fi

    #webrtc安装检查
    docker_webrtc_checAndInstall
}

function docker_webrtc_checAndInstall()
{
    cd webrtc
    if [[ -f "./docker_mediasoup_install.sh" ]]; then
        chmod a+x docker_mediasoup_install.sh
        ./docker_mediasoup_install.sh -i $IPADDRESS -d $BeianAddress -n $Webrtc_Port_Start -m $Webrtc_Port_End
        if [[ $? -eq 0 ]]; then
            echo "./docker_mediasoup_install.sh 执行完成!"
        else
            echo "./docker_mediasoup_install.sh 执行过程中出现错误，已退出安装!"
            exit 1
        fi
    else
        echo "缺少./docker_mediasoup_install.sh 文件...已退出安装!"
        exit 1
    fi
    cd ..
}

function docker_mysql_checkAndInstall(){
    docker_stat $MYSQL_DOCKER_CONTAINER_NAME
    ret=$?
    if [[ ret -eq 2 ]]; then
        echo "MYSQL未安装，即将安装MYSQL"
        cd mysql
        docker_mysql_install
        cd ..
    elif  [[ ret -eq 1 ]]; then
        echo "MYSQL已启动"
    else
        echo "MYSQL未启动，即将启动MYSQL"
        docker start $MYSQL_DOCKER_CONTAINER_NAME
    fi
    
    #创建数据库表检查
    echo "正在进行MYSQL数据库表检查"
    cd mysql
    cp docker_mysql_create_table.sh $MYSQL_DOCKER_PATH/scripts/docker_mysql_create_table.sh
    chmod a+x $MYSQL_DOCKER_PATH/scripts/docker_mysql_create_table.sh
    docker exec -it $MYSQL_DOCKER_CONTAINER_NAME  /bin/bash -c "sh /etc/mysql/scripts/docker_mysql_create_table.sh"
    rm -f $MYSQL_DOCKER_PATH/scripts/docker_mysql_create_table.sh
    cd ..
    
    unset ret
    
}
function docker_mysql_install(){
    echo "安装Docker Mysql环境..."
    if [[ -f "./docker_mysql_install.sh" ]]; then
        # 为执行文件添加权限
        chmod a+x docker_mysql_install.sh
        # Dokcer方式安装Mysql
        ./docker_mysql_install.sh
        if [[ $? -eq 0 ]]; then
            echo "./docker_mysql_install.sh 执行完成!"
            # 测试打印mysql信息
            docker_mysql_install_test
        else
            echo "./docker_mysql_install.sh 执行过程中出现错误，已退出安装!"
            exit 1
        fi
    else
            echo "缺少./docker_mysql_install.sh文件...已退出安装!"
            exit 1
    fi
}
function docker_mysql_install_test()
{
    echo "脚本执行Mysql信息验证:..."
    if [[ -f "./docker_mysql_validator.sh" ]]; then
        # 复制脚本到验证路径并授权
        cp  docker_mysql_validator.sh $MYSQL_DOCKER_PATH/scripts/docker_mysql_validator.sh
        chmod a+x $MYSQL_DOCKER_PATH/scripts/docker_mysql_validator.sh
        # 进入容器执行脚本
        docker exec -it $MYSQL_DOCKER_CONTAINER_NAME  /bin/bash -c "sh /etc/mysql/scripts/docker_mysql_validator.sh"
        if [[ $? -eq 0 ]]; then
            # 删除执行脚本
            rm -f $MYSQL_DOCKER_PATH/scripts/docker_mysql_validator.sh

            echo "./docker_mysql_validator.sh 执行完成!"

        else
            echo "./docker_mysql_validator.sh 执行过程中出现错误，已退出安装!"
            exit 1
        fi
    else
        echo "缺少./docker_mysql_validator.sh文件...已退出安装!"
        exit 1
    fi
} 
function docker_influxdb_checkAndInstall(){
    docker_stat $TSDB_DOCKER_CONTAINER_NAME
    ret=$?
    if [[ ret -eq 2 ]]; then
        echo "$TSDB_DOCKER_CONTAINER_NAME未安装，即将开始安装"
        cd influxdb
        docker_influxdb_install
        cd ..
    elif  [[ ret -eq 1 ]]; then
        echo "$TSDB_DOCKER_CONTAINER_NAME已启动"
    else
        echo "$TSDB_DOCKER_CONTAINER_NAME未启动，即将开始启动"
        docker start $TSDB_DOCKER_CONTAINER_NAME
    fi
    unset ret
    
}

function docker_influxdb_install(){
    echo "=================InfluxDB安装=====start"
    if [[ -f "./docker_influxdb_install.sh" ]]; then
        # 为执行文件添加权限
        chmod a+x docker_influxdb_install.sh
        # Dokcer方式安装Mysql
        ./docker_influxdb_install.sh
        if [[ $? -eq 0 ]]; then
            echo "./docker_influxdb_install.sh 执行完成!"
        else
            echo "./docker_influxdb_install.sh 执行过程中出现错误，已退出安装!"
            exit 1
        fi
    else
            echo "缺少./docker_influxdb_install.sh文件...已退出安装!"
            exit 1
    fi
    echo "=================InfluxDB安装=====start"
}

function docker_grafana_checkAndInstall(){
    docker_stat $GRAFANA_DOCKER_CONTAINER_NAME
    ret=$?
    if [[ ret -eq 2 ]]; then
        echo "grafana未安装，即将开始安装"
        cd grafana
        docker_grafana_install
        cd ..
    elif  [[ ret -eq 1 ]]; then
        echo "$GRAFANA_DOCKER_CONTAINER_NAME已启动"
    else
        echo "$GRAFANA_DOCKER_CONTAINER_NAME未启动，即将开始启动"
        docker start $GRAFANA_DOCKER_CONTAINER_NAME
    fi
    unset ret
    
}
function docker_grafana_install(){
    echo "=================Grafana检查安装=====start"
    echo "安装Docker Grafana环境..."
    if [[ -f "./docker_grafana_install.sh" ]]; then
        # 为执行文件添加权限
        chmod a+x docker_grafana_install.sh
        # Dokcer方式安装Mysql
        ./docker_grafana_install.sh
        if [[ $? -eq 0 ]]; then
            echo "./docker_grafana_install.sh 执行完成!"
        else
            echo "./docker_grafana_install.sh 执行过程中出现错误，已退出安装!"
            exit 1
        fi
    else
            echo "缺少./docker_grafana_install.sh文件...已退出安装!"
            exit 1
    fi
    echo "=================Grafana检查安装=====end"
}

function docker_image_version_exists(){
    for i in [ `docker images  $1` ]; do
        if [[ "$i" == "$2" ]]; then
            return 1;
        fi
    done
    return 0;
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
function updateXmlMultiline()
{
    val=`echo "$3"| sed 's:\/:\\\/:g'`
    echo "正在修改XML文件:$1,节点:$2,新值:$3"
    cat $1  | sed ":label;N;s/\n/\t\t\tnewlinenewlinenewline\t\t\t/;b label" | sed "s/<$2>.*<\/$2>/<$2>$val<\/$2>/g" | sed "s/\t\t\tnewlinenewlinenewline\t\t\t/\n/g" > tmp.xml
    mv tmp.xml $1
    unset val
}

function update_nginx()
{
    val1=`echo "$2"| sed 's:\/:\\\/:g'`
    val2=`echo "$3"| sed 's:\/:\\\/:g'`
    val3=`echo "$4"| sed 's:\/:\\\/:g'`
    val4=`echo "$5"| sed 's:\/:\\\/:g'`
    val5=`echo "$6"| sed 's:\/:\\\/:g'`
    val6=`echo "$7"| sed 's:\/:\\\/:g'`
    echo "正在修改nginx配置文件:$1,on_play:$2,on_play_done:$3"
    sed -i "s/on_play .*/on_play $val1/g" $1
    sed -i "s/on_play_done .*/on_play_done $val2/g" $1
    sed -i "s/listen 4443 ssl;/listen $val3 ssl;/g" $1
    sed -i "s/server wss1002;/server $val4;/g" $1
    sed -i "s/server wss1003;/server $val5;/g" $1
    sed -i "s/server wss1005;/server $val6;/g" $1
    unset val1
    unset val2
    unset val3
    unset val4
    unset val5
    unset val6
}
function update_cluster_conf()
{
    val=`echo "$2"| sed 's:\/:\\\/:g'`
    echo "正在修改ClusterServer配置文件:$1,Addr:$2"
    sed -i "s/{\"Addr\":null}/{\"Addr\":\"$val\"}/g" $1
    unset val
}
function get_free_port(){
    #获取可用端口
    while [ $PORT_DEV_START -lt $PORT_DEV_END ]
    do
        lsof -i:$PORT_DEV_START
        if [[ $? -eq 0 ]]; then
            #端口被占 继续寻找
            let "PORT_DEV_START++"
        else
            echo "端口$PORT_DEV_START可用"
            return 0
        fi
    done
    #端口不够用 程序退出
    echo "端口用尽，发布脚本退出！"
    exit 1
}
function update_config(){
    #获取docker宿主IP
    #DOCKER_GATEWAY_HOST=` docker inspect --format '{{ .NetworkSettings.Gateway }}' $MYSQL_DOCKER_CONTAINER_NAME`
    echo "docker 内部可通过 $DOCKER_GATEWAY_HOST访问宿主"
    let "PORT_DEV_START=PORT_DEV_START+(DOCKER_RUN_ID-1)*30"
    let "DOCKER_RTVS_IP=9+DOCKER_RUN_ID*2"
    let "DOCKER_RTMP_IP=10+DOCKER_RUN_ID*2"
    get_free_port
    DOCKER_HTTP_PORT=$PORT_DEV_START
    let "PORT_DEV_START++"
    
    get_free_port
    DOCKER_HTTPS_PORT=$PORT_DEV_START
    let "PORT_DEV_START++"
    
    get_free_port
    DOCKER_RTMP_PORT=$PORT_DEV_START
    let "PORT_DEV_START++"
    
    get_free_port
    DOCKER_RTMP_STATE_PORT=$PORT_DEV_START
    let "PORT_DEV_START++"
    
    get_free_port
    DOCKER_WSS_PORT=$PORT_DEV_START
    let "PORT_DEV_START++"    
    
    get_free_port
    DOCKER_GOV_PORT=$PORT_DEV_START
    let "PORT_DEV_START++"
    
    get_free_port
    DOCKER_OCX_PORT=$PORT_DEV_START
    let "PORT_DEV_START++"
    
    get_free_port
    DOCKER_WS_PORT=$PORT_DEV_START
    let "PORT_DEV_START++"
    
    get_free_port
    DOCKER_FMP4_PORT=$PORT_DEV_START
    let "PORT_DEV_START++"
    
    if  [ $PORT_DEV_BINDPORT_START -gt 0 ] ;then
        DOCKER_DEV_PORT1=$PORT_DEV_BINDPORT_START
        DOCKER_DEV_PORT2=$(expr $PORT_DEV_BINDPORT_START + 1)
        DOCKER_DEV_PORT3=$(expr $PORT_DEV_BINDPORT_START + 2)
        DOCKER_DEV_PORT4=$(expr $PORT_DEV_BINDPORT_START + 3)
        DOCKER_DEV_PORT5=$(expr $PORT_DEV_BINDPORT_START + 4)
        DOCKER_DEV_PORT6=$(expr $PORT_DEV_BINDPORT_START + 5)
        DOCKER_DEV_PORT7=$(expr $PORT_DEV_BINDPORT_START + 6)
        DOCKER_DEV_PORT8=$(expr $PORT_DEV_BINDPORT_START + 7)
        DOCKER_DEV_PORT9=$(expr $PORT_DEV_BINDPORT_START + 8)
        DOCKER_DEV_PORT10=$(expr $PORT_DEV_BINDPORT_START + 9)
        
        DOCKER_DEV_PORT11=$(expr $PORT_DEV_BINDPORT_START + 10 )
        DOCKER_DEV_PORT12=$(expr $PORT_DEV_BINDPORT_START + 11 )
        DOCKER_DEV_PORT13=$(expr $PORT_DEV_BINDPORT_START + 12 )
        DOCKER_DEV_PORT14=$(expr $PORT_DEV_BINDPORT_START + 13 )
        DOCKER_DEV_PORT15=$(expr $PORT_DEV_BINDPORT_START + 14 )
        DOCKER_DEV_PORT16=$(expr $PORT_DEV_BINDPORT_START + 15 )
        DOCKER_DEV_PORT17=$(expr $PORT_DEV_BINDPORT_START + 16 )
        DOCKER_DEV_PORT18=$(expr $PORT_DEV_BINDPORT_START + 17 )
        DOCKER_DEV_PORT19=$(expr $PORT_DEV_BINDPORT_START + 18 )
        DOCKER_DEV_PORT20=$(expr $PORT_DEV_BINDPORT_START + 19 )
        
    else    
    
        get_free_port
        DOCKER_DEV_PORT1=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT2=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT3=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT4=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT5=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT6=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT7=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT8=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT9=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT10=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT11=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT12=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT13=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT14=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT15=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT16=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT17=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT18=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT19=$PORT_DEV_START
        let "PORT_DEV_START++"
    
        get_free_port
        DOCKER_DEV_PORT20=$PORT_DEV_START
        let "PORT_DEV_START++"
    fi
    
    
    echo "http端口:$DOCKER_HTTP_PORT"
    export DOCKER_HTTP_PORT
    echo "https端口:$DOCKER_HTTPS_PORT"
    export DOCKER_HTTPS_PORT
    echo "上级平台端口:$DOCKER_GOV_PORT"
    export DOCKER_GOV_PORT
    echo "ocx端口:$DOCKER_OCX_PORT"
    export DOCKER_OCX_PORT
    echo "Websocket端口:$DOCKER_WS_PORT"
    export DOCKER_WS_PORT
    echo "fmp4端口:$DOCKER_FMP4_PORT"
    export DOCKER_FMP4_PORT
    echo "rtmp端口:$DOCKER_RTMP_PORT"
    export DOCKER_RTMP_PORT
    echo "rtmp统计页面:$DOCKER_RTMP_STATE_PORT"
    export DOCKER_RTMP_STATE_PORT
    echo "设备端口:$DOCKER_DEV_PORT1 $DOCKER_DEV_PORT2 $DOCKER_DEV_PORT3 $DOCKER_DEV_PORT4 $DOCKER_DEV_PORT5 $DOCKER_DEV_PORT6 $DOCKER_DEV_PORT7 $DOCKER_DEV_PORT8 $DOCKER_DEV_PORT9 $DOCKER_DEV_PORT10 $DOCKER_DEV_PORT11 $DOCKER_DEV_PORT12 $DOCKER_DEV_PORT13 $DOCKER_DEV_PORT14 $DOCKER_DEV_PORT15 $DOCKER_DEV_PORT16 $DOCKER_DEV_PORT17 $DOCKER_DEV_PORT18 $DOCKER_DEV_PORT19 $DOCKER_DEV_PORT20"
 
    
    #车机端口19700-19719 替换为17010-17029?
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT1  19700
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT2  19701
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT3  19702
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT4  19703
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT5  19704
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT6  19705
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT7  19706
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT8  19707
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT9  19708
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT10 19709
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT11 19710
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT12 19711
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT13 19712
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT14 19713
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT15 19714
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT16 19715
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT17 19716
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT18 19717
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT19 19718
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BindPort $DOCKER_DEV_PORT20 19719
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT1  19700
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT2  19701
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT3  19702
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT4  19703
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT5  19704
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT6  19705
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT7  19706
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT8  19707
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT9  19708
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT10 19709
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT11 19710
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT12 19711
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT13 19712
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT14 19713
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT15 19714
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT16 19715
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT17 19716
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT18 19717
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT19 19718
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MappingPort $DOCKER_DEV_PORT20 19719
    
    
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml IsTestMode false
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MatchSim12And20 $MatchSim12And20
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml QueryVideoListTimeOutSec $QueryVideoListTimeOutSec
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml DomainToIP $DomainToIP
    
    #CDN
    if [ -n "$RTVS_CDN_ID" -a  -n "$RTVS_CDN_AKEY" ] ; then
        if [[ "$RTVS_CDN_TYPE" == "0" ]]; then
            RTVS_CDN_TYPE=1
        fi
        
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml CdnAddress $RTVS_CDN_HOST
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml CdnPort $RTVS_CDN_PORT
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml CdnID $RTVS_CDN_ID
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml AKey $RTVS_CDN_AKEY
        echo "RTVS_CDN_TYPE $RTVS_CDN_TYPE"
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml CdnType $RTVS_CDN_TYPE
    fi

    

    #Rtmp地址修改
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml RtmpUrl "rtmp://$DOCKER_NETWORK_IPS.$DOCKER_RTMP_IP/mytv/"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml RtmpUrlPull "rtmp://$BeianAddress:$DOCKER_RTMP_PORT/mytv/"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml HlsUrlPull "http://$BeianAddress:$DOCKER_RTMP_STATE_PORT/hls/"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml HlsUrlPullHttps "https://$BeianAddress:$DOCKER_WSS_PORT/hls/"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml LocIP "$DOCKER_NETWORK_IPS.$DOCKER_RTVS_IP"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml LocPort "80"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml WssPort "$DOCKER_WSS_PORT"
    
    #Webrtc地址
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml WebRTCApi "http://$WEBRTC_DOCKER_IP:88"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml WebRTCUrl "$WEBRTC_RTP_URL"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml WebRTCIP "$BeianAddress"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml WebRTCSslPort "$Webrtc_Port_Start"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml WebRTCPort "$((Webrtc_Port_Start+1))"
    
    #
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml FDTCPPort $DOCKER_OCX_PORT
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml FDWebSocketPort $DOCKER_WS_PORT
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml FDFMP4Port $DOCKER_FMP4_PORT
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml GovPort $DOCKER_GOV_PORT
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml VideoCachePath "/VideoCache/"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml IPAddress $IPADDRESS
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml BeianAddress $BeianAddress
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml FDWebPort $DOCKER_HTTP_PORT


    #修改nginx-rtmp配置
    update_nginx $DOCKER_NGINX_PATH/nginx.conf "http://$DOCKER_NETWORK_IPS.$DOCKER_RTVS_IP/WebService/NginxOnPlay;" "http://$DOCKER_NETWORK_IPS.$DOCKER_RTVS_IP/WebService/NginxOnPlayDown;" "$DOCKER_WSS_PORT" "$DOCKER_NETWORK_IPS.$DOCKER_RTVS_IP:$DOCKER_WS_PORT"  "$DOCKER_NETWORK_IPS.$DOCKER_RTVS_IP:$DOCKER_FMP4_PORT"  "$DOCKER_NETWORK_IPS.$DOCKER_RTVS_IP:$DOCKER_GOV_PORT" 
    
    
    #修改InfluxdbBaseUrl配置
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml InfluxdbBaseUrl "$InfluxdbBaseUrl"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml MysqlConnectionString "$MysqlConnectionString"
    
    #修改版本
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml Ver $DOCKER_RTVSWEB_VERSION
    
    #证书
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml X509FileName "/MyData/certificate.pfx"
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml X509Password "$CV_PFX_PWD"
    

    #修改传入参数
    if  [ ! -n "$GovWebIp" ] ;then
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml GovWebIp $BeianAddress
    else
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml GovWebIp $GovWebIp
    fi
    if  [ ! -n "$FDWebIP" ] ;then
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml FDWebIP http://$DOCKER_GATEWAY_HOST
    else
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml FDWebIP http://$FDWebIP
    fi
    if  [ ! -n "$GatewayBaseAPI" ] ;then
        echo "GatewayBaseAPI无需修改"
    else
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml GatewayBaseAPI $GatewayBaseAPI
    fi

    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml GB28181API $GB28181API

    if  [ ! -n "$RedisExchangeHosts" ] ;then
        echo "RedisExchangeHosts无需修改"
    else
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml RedisExchangeHosts $RedisExchangeHosts
    fi
    if  [ ! -n "$GrafanaDashboardUrl" ] ;then
        echo "GrafanaDashboardUrl无需修改"
    else
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml GrafanaDashboardUrl $GrafanaDashboardUrl
    fi
    if  [ ! -n "$ClusterServer" ] ;then
        update_cluster_conf $DOCKER_RTVSWEB_PATH/Config/ClusterServer.json "http://$DOCKER_GATEWAY_HOST:30888/Api"
    elif  [[ "$ClusterServer" == "null" ]]; then
        echo "ClusterServer无需修改"
    else
        update_cluster_conf $DOCKER_RTVSWEB_PATH/Config/ClusterServer.json $ClusterServer
    fi
    
    
    if  [ ! -n "$WebUsrName" ] ;then
        echo "WebUsrName无需修改"
    else
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml WebUsrName $WebUsrName
    fi
    
    
    if  [ ! -n "$WebUsrPwd" ] ;then
        echo "WebUsrPwd无需修改"
    else
        updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml WebUsrPwd $WebUsrPwd
    fi
    
    #TagConfs
    updateXml $DOCKER_RTVSWEB_PATH/SettingConfig.xml TagConfs "$TagConfs"
}
function docker_run(){
    #启动nginx-rtmp
    docker run -d \
    -p $DOCKER_RTMP_PORT:1935 \
    -p $DOCKER_RTMP_STATE_PORT:8080 \
    -p $DOCKER_WSS_PORT:$DOCKER_WSS_PORT \
    -v $DOCKER_NGINX_PATH/nginx.conf:/opt/nginx/conf/nginx.conf \
    -v $DOCKER_NGINX_PATH/cert:/opt/nginx/conf/cert \
    --name $DOCKER_NGINX_CONTAINER_NAME \
    --net $DOCKER_NETWORK \
    --ip $DOCKER_NETWORK_IPS.$DOCKER_RTMP_IP\
    --restart always  \
    $NGINX_DOCKER_IMAGE_NAME
    
    docker pull $RTVSWEB_DOCKER_IMAGE_NAME:$DOCKER_RTVSWEB_VERSION
    #启动RTVS
    docker run  \
    --name $DOCKER_RTVSWEB_CONTAINER_NAME \
    --net $DOCKER_NETWORK \
    --ip $DOCKER_NETWORK_IPS.$DOCKER_RTVS_IP\
    --restart always  \
    --privileged=true  \
    -v $DOCKER_RTVSWEB_PATH:/MyData \
    -v /etc/service/rtvsvideocache:/VideoCache \
    -e MyDataPath=/MyData \
    -p $DOCKER_HTTP_PORT:80 \
    -p $DOCKER_HTTPS_PORT:443 \
    -p $DOCKER_GOV_PORT:$DOCKER_GOV_PORT \
    -p $DOCKER_OCX_PORT:$DOCKER_OCX_PORT \
    -p $DOCKER_WS_PORT:$DOCKER_WS_PORT \
    -p $DOCKER_FMP4_PORT:$DOCKER_FMP4_PORT \
    -p $DOCKER_DEV_PORT1:$DOCKER_DEV_PORT1 \
    -p $DOCKER_DEV_PORT2:$DOCKER_DEV_PORT2 \
    -p $DOCKER_DEV_PORT3:$DOCKER_DEV_PORT3 \
    -p $DOCKER_DEV_PORT4:$DOCKER_DEV_PORT4 \
    -p $DOCKER_DEV_PORT5:$DOCKER_DEV_PORT5 \
    -p $DOCKER_DEV_PORT6:$DOCKER_DEV_PORT6 \
    -p $DOCKER_DEV_PORT7:$DOCKER_DEV_PORT7 \
    -p $DOCKER_DEV_PORT8:$DOCKER_DEV_PORT8 \
    -p $DOCKER_DEV_PORT9:$DOCKER_DEV_PORT9 \
    -p $DOCKER_DEV_PORT10:$DOCKER_DEV_PORT10 \
    -p $DOCKER_DEV_PORT11:$DOCKER_DEV_PORT11 \
    -p $DOCKER_DEV_PORT12:$DOCKER_DEV_PORT12 \
    -p $DOCKER_DEV_PORT13:$DOCKER_DEV_PORT13 \
    -p $DOCKER_DEV_PORT14:$DOCKER_DEV_PORT14 \
    -p $DOCKER_DEV_PORT15:$DOCKER_DEV_PORT15 \
    -p $DOCKER_DEV_PORT16:$DOCKER_DEV_PORT16 \
    -p $DOCKER_DEV_PORT17:$DOCKER_DEV_PORT17 \
    -p $DOCKER_DEV_PORT18:$DOCKER_DEV_PORT18 \
    -p $DOCKER_DEV_PORT19:$DOCKER_DEV_PORT19 \
    -p $DOCKER_DEV_PORT20:$DOCKER_DEV_PORT20 \
    -d $RTVSWEB_DOCKER_IMAGE_NAME:$DOCKER_RTVSWEB_VERSION
}
function main(){
    #安装基础docker镜像
    docker_base_install
    
    
    #找到能运行的rtvs名称
    docker_set_DOCKER_RTVSWEB_CONTAINER_NAME
    if [[ $? -eq 0 ]]; then
        echo "未找到可执行DOCKER_RUN_ID，已退出安装！"
        exit 1        
    fi
    echo "找到可执行DOCKER_RUN_ID:$DOCKER_RUN_ID"
    DOCKER_NGINX_CONTAINER_NAME=$NGINX_DOCKER_CONTAINER_NAME_TEMPLATE$DOCKER_RUN_ID;
    docker rm -f $DOCKER_NGINX_CONTAINER_NAME 2>/dev/null


    echo "依耐文件检查...."
    init_system_files_path

    
    #修改配置
    update_config
    
    
    #启动镜像
    docker_run
    
    echo "RTVS启动完成"
    echo ""
}
function helpinfo(){
    echo "help 待完善"
}
###################################脚本入口#######################################


if  [ ! -n "$IPADDRESS" ] ;then
    echo "必须传入IPADDRESS"
    helpinfo
    
elif [ ! -n "$GatewayBaseAPI" ] ; then
    echo "必须传入GatewayBaseAPI"
    helpinfo
elif [ ! -n "$RedisExchangeHosts" ] ; then
    echo "必须传入RedisExchangeHosts"
    helpinfo
else
    if [ ! -n "$BeianAddress" ] ; then
        echo "未传入备案域名，默认为IPADDRESS值$IPADDRESS"
        BeianAddress=$IPADDRESS
    fi
    main 
fi

