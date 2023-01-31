#! /bin/bash
echo "当前执行文件......$0"
IS_EXISTS_INFLUXDB_IMAGE_NAME="false"
IS_EXISTS_INFLUXDB_CONTAINER="false"
IS_EXISTS_INFLUXDB_CONTAINER_RUNGING="false"
START_CONTAINER_CHECK_MAX_TIMES=3
START_CONTAINER_CHECK_CURRENT=1

#传入表示映射出端口
#TSDB_Server_PORT
source ../default_args.sh

# ========================下载镜像======================================
for i in [ `docker images ` ]; do
    
    if [[ "$i" == "docker.io/influxdb" ||  "$i" == "influxdb" ]]; then
        echo "$i"
        IS_EXISTS_INFLUXDB_IMAGE_NAME="true"
        break
    fi
done
if [[ $IS_EXISTS_INFLUXDB_IMAGE_NAME == "true"  ]]; then
    echo "本地已存在influxdb:$INFLUXDB_VERSION镜像，不再重新下载......."
else
    echo "本地不存在influxdb:$INFLUXDB_VERSION镜像，正在下载......."
    docker pull influxdb:$INFLUXDB_VERSION
fi

# ====================创建镜像===========================================
if [[ $IS_EXISTS_INFLUXDB_CONTAINER == "false" ]]; then
    echo "检查influxdb容器是否创建......"
    for i in [ `docker ps -a` ]; do
        if [[ "$i" == "$TSDB_DOCKER_CONTAINER_NAME" ]]; then
            IS_EXISTS_INFLUXDB_CONTAINER="true"
            break
        fi
    done
    if [[ $IS_EXISTS_INFLUXDB_CONTAINER == "false" ]]; then
        cp docker_influxdb_create_user.sh $TSDB_DOCKER_PATH/scripts/docker_influxdb_create_user.sh
        cp influxdb.conf $TSDB_DOCKER_PATH/influxdb.conf
        chmod a+x $TSDB_DOCKER_PATH/scripts/docker_influxdb_create_user.sh
        if [[ -f "$TSDB_DOCKER_PATH/scripts/docker_influxdb_create_user.sh" ]]; then
            echo "检查到influxdb容器尚未创建!"
            # 执行容器创建
            # 运行容器实例 --privileged=true 获取管理员权限
            echo "创建influxdb容器实例..."
            if  [ -n "$TSDB_Server_PORT" ] ;then
                docker run -d --restart always -p $TSDB_Server_PORT:8086 --name $TSDB_DOCKER_CONTAINER_NAME --net $DOCKER_NETWORK --ip $TSDB_DOCKER_IP   --privileged=true -v $TSDB_DOCKER_PATH/dockerdata:/var/lib/influxdb -v $TSDB_DOCKER_PATH:/etc/influxdb influxdb:$INFLUXDB_VERSION
            else
                docker run -d --restart always  --name $TSDB_DOCKER_CONTAINER_NAME --net $DOCKER_NETWORK --ip $TSDB_DOCKER_IP   --privileged=true -v $TSDB_DOCKER_PATH/dockerdata:/var/lib/influxdb -v $TSDB_DOCKER_PATH:/etc/influxdb influxdb:$INFLUXDB_VERSION
            fi
            # 休10秒钟
            echo "休眠等待10s以便Docker完成容器运行......"
            sleep 10s
            echo "进入influxdb容器: docker exec -it $TSDB_DOCKER_CONTAINER_NAME  /bin/bash -c 'sh /etc/influxdb/scripts/docker_influxdb_create_user.sh'"
            # 进入容器并执行脚本：
            docker exec -it $TSDB_DOCKER_CONTAINER_NAME  /bin/bash -c "sh /etc/influxdb/scripts/docker_influxdb_create_user.sh"
            # 删除执行文件
            rm -f $TSDB_DOCKER_PATH/scripts/docker_influxdb_create_user.sh

            echo "influxdb容器已创建完毕!"

            IS_EXISTS_INFLUXDB_CONTAINER_RUNGING=true
        else
            echo "$TSDB_DOCKER_PATH/scripts/docker_influxdb_create_user.sh文件不存在，docker需要用此文件创建influxdb容器实例并创建用户."
            exit 1
        fi
    else
        echo "检查到influxdb容器已创建!"
    fi
fi
# ===================启动或重启容器================================
if [[ $IS_EXISTS_INFLUXDB_CONTAINER == "true" && $IS_EXISTS_INFLUXDB_CONTAINER_RUNGING == "false" ]]; then
    echo "下面最多执行三次influxdb容器检查重启..."
    while [[ $START_CONTAINER_CHECK_CURRENT -le $START_CONTAINER_CHECK_MAX_TIMES ]]; do
        echo "检查influxdb容器状态......$START_CONTAINER_CHECK_CURRENT"
        for i in [ `docker ps ` ]; do
            if [[ "$i" == "$TSDB_DOCKER_CONTAINER_NAME" ]]; then
                IS_EXISTS_INFLUXDB_CONTAINER_RUNGING="true"
                break
            fi
        done
        if [[ $IS_EXISTS_INFLUXDB_CONTAINER_RUNGING == "false" ]]; then
            echo "检查到influxdb容器当前不在运行状态!"
            echo "启动influxdb容器...."
            docker start $TSDB_DOCKER_CONTAINER_NAME
            for i in [ `docker ps ` ]; do
                if [[ "$i" == "$TSDB_DOCKER_CONTAINER_NAME" ]]; then
                    IS_EXISTS_INFLUXDB_CONTAINER_RUNGING="true"
                    break
                fi
            done
            if [[ $IS_EXISTS_INFLUXDB_CONTAINER_RUNGING == "true" ]]; then
                echo "influxdb容器已经在运行!"
                break
            fi
        else
            echo "influxdb容器已经在运行!"
            break
        fi
        START_CONTAINER_CHECK_CURRENT=$((START_CONTAINER_CHECK_CURRENT+1))
    done
    if [[ $IS_EXISTS_INFLUXDB_CONTAINER_RUNGING == "false" ]]; then
        echo "检查到influxdb容器当前仍未运行,请联系相关人员进行处理!"
        exit 1
    fi
fi
