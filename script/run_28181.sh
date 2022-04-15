#! /bin/bash
echo "当前执行文件......$0"

##################################变量定义##################################
DOCKER_GB2JT_NAME=${DOCKER_GB2JT_NAME:-"gb2jt-1"}
DOCKER_GB2JT_PATH=${DOCKER_GB2JT_PATH:-"/etc/service/$DOCKER_GB2JT_NAME"}
DOCKER_GB2JT_IMAGE_NAME=${DOCKER_GB2JT_IMAGE_NAME:-"vanjoge/gb2jt:1.3.3"}


#外网IP

#端口  

DOCKER_SIP_PORT=${DOCKER_SIP_PORT:-5060}
DOCKER_RTP_PORT=${DOCKER_RTP_PORT:-30000}

DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
DOCKER_GB2JT_IP=${DOCKER_GB2JT_IP:-"172.29.108.248"}

#0 UDP 1 TCP
GB28181_RTP_TYPE=${GB28181_RTP_TYPE:-"1"}

#808
Server_808_ADDR=${Server_808_ADDR:-"172.29.108.249"}
DOCKER_808_PORT=${DOCKER_808_PORT:-"9300"}
 
 
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
    if [[ ! -d $DOCKER_GB2JT_PATH ]]; then
        mkdir $DOCKER_GB2JT_PATH
    fi
    cd gb28181
    # 复制Setting.xml
    if [[ -f "./Setting.xml" ]]; then
        echo "拷贝文件： ./Setting.xml $DOCKER_GB2JT_PATH/Setting.xml"
        cp -f Setting.xml $DOCKER_GB2JT_PATH/Setting.xml
    else
        echo "缺少./Setting.xml文件...已退出安装!"
        exit
    fi
    # 复制siplog4.config
    if [[ -f "./siplog4.config" ]]; then
        echo "拷贝文件： ./siplog4.config $DOCKER_GB2JT_PATH/siplog4.config"
        cp -f siplog4.config $DOCKER_GB2JT_PATH/siplog4.config
    else
        echo "缺少./siplog4.config文件...已退出安装!"
        exit
    fi
    
    # 复制log4.config
    if [[ -f "./log4.config" ]]; then
        echo "拷贝一份日志配置文件： ./log4.config $DOCKER_GB2JT_PATH/log4.config"
        cp  -f ./log4.config $DOCKER_GB2JT_PATH/log4.config
    else
        echo "缺少./log4.config文件...已退出安装!"
        exit
    fi
    cd ..
}
 
function docker_run(){
    updateXml $DOCKER_GB2JT_PATH/Setting.xml RtpType "$GB28181_RTP_TYPE"
    updateXml $DOCKER_GB2JT_PATH/Setting.xml ServerIP "$IPADDRESS"
    updateXml $DOCKER_GB2JT_PATH/Setting.xml SipPort "$DOCKER_SIP_PORT"
    updateXml $DOCKER_GB2JT_PATH/Setting.xml RtpPort "$DOCKER_RTP_PORT"
    updateXml $DOCKER_GB2JT_PATH/Setting.xml Server808 "$Server_808_ADDR"
    updateXml $DOCKER_GB2JT_PATH/Setting.xml Prot808 "$DOCKER_808_PORT"
	
	
	docker pull $DOCKER_GB2JT_IMAGE_NAME
    #启动RTVS
    docker run  --name $DOCKER_GB2JT_NAME --net $DOCKER_NETWORK --ip $DOCKER_GB2JT_IP --restart always  --privileged=true  -v $DOCKER_GB2JT_PATH:/MyData  -e MyDataPath=/MyData -p $DOCKER_SIP_PORT:$DOCKER_SIP_PORT -p $DOCKER_RTP_PORT:$DOCKER_RTP_PORT  -d $DOCKER_GB2JT_IMAGE_NAME
}
function main(){
    echo "依耐文件检查...."
    init_system_files_path
    
    #启动镜像
    docker_run
    
    echo "GB28281服务启动完成"
    echo ""
}
###################################脚本入口#######################################

    main 
