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
    if [ -n "$CV_PFX_PATH" ]; then
        if [[ -f "$CV_PFX_PATH" ]]; then
            echo "拷贝证书： $CV_PFX_PATH $DOCKER_CLUSTER_PATH/certificate.pfx"
            cp -f $CV_PFX_PATH $DOCKER_CLUSTER_PATH/certificate.pfx
        else
            echo "缺少$CV_PFX_PATH文件...已退出安装!"
            exit 1
        fi
    else
        rm $DOCKER_CLUSTER_PATH/certificate.pfx 2>/dev/null
    fi

    if [ -n "$CV_PEM_PATH" ]; then
        if [[ -f "$CV_PEM_PATH" ]]; then
            echo "拷贝pem证书： $CV_PEM_PATH $DOCKER_CLUSTER_PATH/certificate.crt"
            cp -f $CV_PEM_PATH $DOCKER_CLUSTER_PATH/certificate.crt
        else
            echo "缺少$CV_PEM_PATH文件...已退出安装!"
            exit 1
        fi
    else
        rm $DOCKER_CLUSTER_PATH/certificate.crt 2>/dev/null
    fi

    if [ -n "$CV_PEMKEY_PATH" ]; then
        if [[ -f "$CV_PEMKEY_PATH" ]]; then
            echo "拷贝私钥： $CV_PEMKEY_PATH $DOCKER_CLUSTER_PATH/privkey.pem"
            cp -f $CV_PEMKEY_PATH $DOCKER_CLUSTER_PATH/privkey.pem
        else
            echo "缺少$CV_PEMKEY_PATH文件...已退出安装!"
            exit 1
        fi
    else
        rm $DOCKER_CLUSTER_PATH/privkey.pem 2>/dev/null
    fi
    
    # 复制log4.config
    if [[ -f "./log4.config" ]]; then
        echo "拷贝一份日志配置文件： ./log4.config $DOCKER_CLUSTER_PATH/log4.config"
        cp -f ./log4.config $DOCKER_CLUSTER_PATH/log4.config
    else
        echo "缺少./log4.config文件...已退出安装!"
        exit
    fi
    cd ..
}
 
function docker_run(){
    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml WsPort "$DOCKER_WEBSOCKET_PORT"

    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml X509FileName "/MyData/certificate.pfx"
    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml X509Password "$CV_PFX_PWD"
    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml PemFileName "/MyData/certificate.crt"
    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml PemKeyFileName "/MyData/privkey.pem"

    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml CdnUrl "$RTVS_CDN_URL"
    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml CdnID "$RTVS_CDN_ID"
    updateXml $DOCKER_CLUSTER_PATH/ApiServer.xml AKey "$RTVS_CDN_AKEY"
    
    
    if [[ "$RTVS_UPDATECHECK_DOCKER" == "true" ]]; then
        docker pull $DOCKER_CLUSTER_IMAGE_NAME
    fi
    #启动集群管理
    if [[ "$RTVS_NETWORK_HOST" == "true" ]]; then
        docker run  --name $DOCKER_CLUSTER_NAME --net host --restart always  --privileged=true  -v $DOCKER_CLUSTER_PATH:/MyData  -e MyDataPath=/MyData -e ASPNETCORE_URLS="http://*:$DOCKER_HTTP_PORT" -d $DOCKER_CLUSTER_IMAGE_NAME
    else
        docker run  --name $DOCKER_CLUSTER_NAME --net $DOCKER_NETWORK --ip $DOCKER_CVCLUSTER_IP --restart always  --privileged=true  -v $DOCKER_CLUSTER_PATH:/MyData  -e MyDataPath=/MyData -p $DOCKER_HTTP_PORT:80 -p $DOCKER_HTTPS_PORT:443  -p $DOCKER_WEBSOCKET_PORT:$DOCKER_WEBSOCKET_PORT  -d $DOCKER_CLUSTER_IMAGE_NAME
    fi
}
function main(){
    echo "依赖文件检查...."
    init_system_files_path
    
    #启动镜像
    docker_run
    
    echo "集群管理启动完成"
    echo ""
}
###################################脚本入口#######################################

    main 
