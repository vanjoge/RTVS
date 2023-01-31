#! /bin/bash
echo "当前执行文件......$0"

source default_args.sh

 
 
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
    if [[ -f "./Setting_gb2jt.xml" ]]; then
        echo "拷贝文件： ./Setting_gb2jt.xml $DOCKER_GB2JT_PATH/Setting.xml"
        cp -f Setting.xml $DOCKER_GB2JT_PATH/Setting.xml
    else
        echo "缺少./Setting_gb2jt.xml文件...已退出安装!"
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
    updateXml $DOCKER_GB2JT_PATH/Setting.xml Server808 "$DOCKER_GW_IP"
    updateXml $DOCKER_GB2JT_PATH/Setting.xml Prot808 "$DOCKER_808_PORT"
    
    if [[ "$RTVS_UPDATECHECK_DOCKER" == "true" ]]; then
        docker pull $DOCKER_GB2JT_IMAGE_NAME
    fi
    #启动RTVS
    docker run  --name $DOCKER_GB2JT_NAME --net $DOCKER_NETWORK --ip $DOCKER_GB2JT_IP --restart always  --privileged=true  -v $DOCKER_GB2JT_PATH:/MyData  -e MyDataPath=/MyData -p $DOCKER_SIP_PORT:$DOCKER_SIP_PORT/tcp -p $DOCKER_SIP_PORT:$DOCKER_SIP_PORT/udp -p $DOCKER_RTP_PORT:$DOCKER_RTP_PORT/tcp -p $DOCKER_RTP_PORT:$DOCKER_RTP_PORT/udp  -d $DOCKER_GB2JT_IMAGE_NAME
}
function main(){
    echo "依赖文件检查...."
    init_system_files_path
    
    #启动镜像
    docker_run
    
    echo "GB28181服务启动完成"
    echo ""
}
###################################脚本入口#######################################

    main 
