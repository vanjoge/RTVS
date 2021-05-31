#! /bin/bash

function update_dburl()
{

    val1=`echo "$2"| sed 's:\/:\\\/:g'`
    echo "正在修改nginx配置文件:$1,url:$2"
    sed -i "s/url: .*/url: $val1/g" $1
    unset val1
}

echo "当前执行文件......$0"
IS_EXISTS_GRAFANA_IMAGE_NAME="false"
IS_EXISTS_GRAFANA_CONTAINER="false"
IS_EXISTS_GRAFANA_CONTAINER_RUNGING="false"
START_CONTAINER_CHECK_MAX_TIMES=3
START_CONTAINER_CHECK_CURRENT=1
GRAFANA_VERSION=${GRAFANA_VERSION:-"5.4.0"}

DOCKER_NETWORK=${DOCKER_NETWORK:-"cvnetwork"}
GRAFANA_DOCKER_IP=${GRAFANA_DOCKER_IP:-"172.29.108.243"}
TSDB_DOCKER_IP=${TSDB_DOCKER_IP:-"172.29.108.242"}
GRAFANA_DOCKER_CONTAINER_NAME=${GRAFANA_DOCKER_CONTAINER_NAME:-"grafana"}
GRAFANA_DOCKER_PATH=${GRAFANA_DOCKER_PATH:-"/etc/grafana"}
GRAFANA_DOCKER_PORT=${GRAFANA_DOCKER_PORT:-33000}


# ========================下载镜像======================================
for i in [ `docker images ` ]; do
    
    if [[ "$i" == "docker.io/grafana/grafana" ||  "$i" == "grafana/grafana" ]]; then
        echo "$i"
        IS_EXISTS_GRAFANA_IMAGE_NAME="true"
        break
    fi
done
if [[ $IS_EXISTS_GRAFANA_IMAGE_NAME == "true"  ]]; then
    echo "本地已存在grafana:$GRAFANA_VERSION镜像，不再重新下载......."
else
    echo "本地不存在grafana:$GRAFANA_VERSION镜像，正在下载......."
    docker pull grafana/grafana:$GRAFANA_VERSION
fi

# ====================创建镜像===========================================
if [[ $IS_EXISTS_GRAFANA_CONTAINER == "false" ]]; then
    echo "检查$GRAFANA_DOCKER_CONTAINER_NAME容器是否创建......"
    for i in [ `docker ps -a` ]; do
        if [[ "$i" == "$GRAFANA_DOCKER_CONTAINER_NAME" ]]; then
            IS_EXISTS_GRAFANA_CONTAINER="true"
            break
        fi
    done
    if [[ $IS_EXISTS_GRAFANA_CONTAINER == "false" ]]; then
        cp -f ./defaults.ini $GRAFANA_DOCKER_PATH/conf/defaults.ini
        cp -f ./dashboards.yaml $GRAFANA_DOCKER_PATH/conf/dashboards.yaml
        cp -f ./InfluxDB.yaml $GRAFANA_DOCKER_PATH/conf/InfluxDB.yaml
        cp -f ./zaixin.json $GRAFANA_DOCKER_PATH/conf/zaixin.json
        if [[ -f "$GRAFANA_DOCKER_PATH/conf/defaults.ini" ]]; then
            echo "检查到$GRAFANA_DOCKER_CONTAINER_NAME容器尚未创建!"
			#DOCKER_GATEWAY_HOST=` docker inspect --format '{{ .NetworkSettings.Gateway }}' mysql5.7`
			update_dburl $GRAFANA_DOCKER_PATH/conf/InfluxDB.yaml "http://$TSDB_DOCKER_IP:8086"
            # 运行容器实例 --privileged=true 获取管理员权限
            echo "创建$GRAFANA_DOCKER_CONTAINER_NAME容器实例..."
            docker run -d -p $GRAFANA_DOCKER_PORT:3000 \
            --restart always \
            --name $GRAFANA_DOCKER_CONTAINER_NAME \
	        --net $DOCKER_NETWORK \
	        --ip $GRAFANA_DOCKER_IP \
            --privileged=true \
            -v $GRAFANA_DOCKER_PATH/conf/defaults.ini:/usr/share/grafana/conf/defaults.ini \
            -v $GRAFANA_DOCKER_PATH/conf/InfluxDB.yaml:/etc/grafana/provisioning/datasources/InfluxDB.yaml \
            -v $GRAFANA_DOCKER_PATH/conf/dashboards.yaml:/etc/grafana/provisioning/dashboards/dashboards.yaml \
            -v $GRAFANA_DOCKER_PATH/conf/zaixin.json:/etc/grafana/provisioning/dashboards/zaixin.json \
            grafana/grafana:$GRAFANA_VERSION
            #需要导入配置

            echo "$GRAFANA_DOCKER_CONTAINER_NAME容器已创建完毕!"
            IS_EXISTS_GRAFANA_CONTAINER_RUNGING=true
        else
            echo "$GRAFANA_DOCKER_PATH/conf/defaults.ini文件不存在，docker需要将此文件用于$GRAFANA_DOCKER_CONTAINER_NAME容器配置."
            exit 1
        fi
        
    else
        echo "检查到$GRAFANA_DOCKER_CONTAINER_NAME容器已创建!"
    fi
fi
# ===================启动或重启容器================================
if [[ $IS_EXISTS_GRAFANA_CONTAINER == "true" && $IS_EXISTS_GRAFANA_CONTAINER_RUNGING == "false" ]]; then
    echo "下面最多执行三次$GRAFANA_DOCKER_CONTAINER_NAME容器检查重启..."
    while [[ $START_CONTAINER_CHECK_CURRENT -le $START_CONTAINER_CHECK_MAX_TIMES ]]; do
        echo "检查$GRAFANA_DOCKER_CONTAINER_NAME容器状态......$START_CONTAINER_CHECK_CURRENT"
        for i in [ `docker ps ` ]; do
            if [[ "$i" == "$GRAFANA_DOCKER_CONTAINER_NAME" ]]; then
                IS_EXISTS_GRAFANA_CONTAINER_RUNGING="true"
                break
            fi
        done
        if [[ $IS_EXISTS_GRAFANA_CONTAINER_RUNGING == "false" ]]; then
            echo "检查到$GRAFANA_DOCKER_CONTAINER_NAME容器当前不在运行状态!"
            echo "启动$GRAFANA_DOCKER_CONTAINER_NAME容器...."
            docker start $GRAFANA_DOCKER_CONTAINER_NAME
            for i in [ `docker ps ` ]; do
                if [[ "$i" == "$GRAFANA_DOCKER_CONTAINER_NAME" ]]; then
                    IS_EXISTS_GRAFANA_CONTAINER_RUNGING="true"
                    break
                fi
            done
            if [[ $IS_EXISTS_GRAFANA_CONTAINER_RUNGING == "true" ]]; then
                echo "$GRAFANA_DOCKER_CONTAINER_NAME容器已经在运行!"
                break
            fi
        else
            echo "$GRAFANA_DOCKER_CONTAINER_NAME容器已经在运行!"
            break
        fi
        START_CONTAINER_CHECK_CURRENT=$((START_CONTAINER_CHECK_CURRENT+1))
    done
    if [[ $IS_EXISTS_GRAFANA_CONTAINER_RUNGING == "false" ]]; then
        echo "检查到$GRAFANA_DOCKER_CONTAINER_NAME容器当前仍未运行,请联系相关人员进行处理!"
        exit 1
    fi
fi
