#! /bin/bash
echo "当前执行文件......$0"

source ../default_args.sh

IS_EXISTS_MYSQL_IMAGE_NAME="false"
IS_EXISTS_MYSQL_IMAGE_TAG="false"
IS_EXISTS_MYSQL_CONTAINER="false"
IS_EXISTS_MYSQL_CONTAINER_RUNGING="false"
START_CONTAINER_CHECK_MAX_TIMES=3
START_CONTAINER_CHECK_CURRENT=1

#传入表示映射出端口
#MYSQL_Server_PORT

# ========================下载镜像======================================
for i in [ `docker images ` ]; do
    
    if [[ "$i" == "docker.io/$MYSQL_DOCKER_IMAGE_NAME" ||  "$i" == "$MYSQL_DOCKER_IMAGE_NAME" ]]; then
        echo "$i"
        IS_EXISTS_MYSQL_IMAGE_NAME="true"
    fi
    if [[ "$i" == "$MYSQL_DOCKER_IMAGE_VERSION" ]]; then
        echo "$i"
        IS_EXISTS_MYSQL_IMAGE_TAG="true"
    fi
done
if [[ $IS_EXISTS_MYSQL_IMAGE_NAME == "true" && $IS_EXISTS_MYSQL_IMAGE_TAG == "true" ]]; then
    echo "本地已存在$MYSQL_DOCKER_IMAGE_NAME:$MYSQL_DOCKER_IMAGE_VERSION镜像，不再重新下载......."
else
    echo "本地不存在$MYSQL_DOCKER_IMAGE_NAME:$MYSQL_DOCKER_IMAGE_VERSION镜像，正在下载......."
    docker pull $MYSQL_DOCKER_IMAGE_NAME:$MYSQL_DOCKER_IMAGE_VERSION
fi

# ====================创建镜像===========================================
if [[ $IS_EXISTS_MYSQL_CONTAINER == "false" ]]; then
    echo "检查$MYSQL_DOCKER_CONTAINER_NAME容器是否创建......"
    for i in [ `docker ps -a` ]; do
        if [[ "$i" == "$MYSQL_DOCKER_CONTAINER_NAME" ]]; then
            IS_EXISTS_MYSQL_CONTAINER="true"
            break
        fi
    done
    if [[ $IS_EXISTS_MYSQL_CONTAINER == "false" ]]; then
        echo "检查到$MYSQL_DOCKER_CONTAINER_NAME容器尚未创建!"
        echo "创建$MYSQL_DOCKER_CONTAINER_NAME容器......."
        # 拷贝可执行文件并授权
        cp docker_mysql_db_init.sh $MYSQL_DOCKER_PATH/scripts/docker_mysql_db_init.sh
        chmod a+x $MYSQL_DOCKER_PATH/scripts/docker_mysql_db_init.sh
        # 执行容器创建
        if [[ -f "$MYSQL_DOCKER_PATH/scripts/docker_mysql_db_init.sh" ]]; then
            # 运行容器实例 --privileged=true 获取管理员权限
            echo "创建$MYSQL_DOCKER_CONTAINER_NAME容器实例..."
            if  [ -n "$MYSQL_Server_PORT" ] ;then
                docker run -d -p $MYSQL_Server_PORT:3306 --name $MYSQL_DOCKER_CONTAINER_NAME --net $DOCKER_NETWORK --ip $MYSQL_DOCKER_IP  --restart always --privileged=true -v $MYSQL_DOCKER_PATH/conf.d:/etc/mysql/conf.d -v $MYSQL_DOCKER_PATH/logs:/logs -v $MYSQL_DOCKER_PATH/data:/var/lib/mysql -v $MYSQL_DOCKER_PATH/scripts:/etc/mysql/scripts -e MYSQL_ROOT_PASSWORD=root  $MYSQL_DOCKER_IMAGE_NAME:$MYSQL_DOCKER_IMAGE_VERSION
            else
                docker run -d  --name $MYSQL_DOCKER_CONTAINER_NAME --net $DOCKER_NETWORK --ip $MYSQL_DOCKER_IP  --restart always --privileged=true -v $MYSQL_DOCKER_PATH/conf.d:/etc/mysql/conf.d -v $MYSQL_DOCKER_PATH/logs:/logs -v $MYSQL_DOCKER_PATH/data:/var/lib/mysql -v $MYSQL_DOCKER_PATH/scripts:/etc/mysql/scripts -e MYSQL_ROOT_PASSWORD=root  $MYSQL_DOCKER_IMAGE_NAME:$MYSQL_DOCKER_IMAGE_VERSION
            fi
            # 映射copy文件路径到docker容器
            # echo "执行文件拷贝: cp $MYSQL_DOCKER_PATH/scripts/docker_mysql_db_init.sh $MYSQL_DOCKER_CONTAINER_NAME:/etc/mysql/scripts/docker_mysql_db_init.sh"
            # docker cp $MYSQL_DOCKER_PATH/scripts/docker_mysql_db_init.sh $MYSQL_DOCKER_CONTAINER_NAME:/etc/mysql/scripts/docker_mysql_db_init.sh
            # 休10秒钟
            echo "休眠等待30s以便Docker完成容器运行和路径映射......"
            sleep 30s
            # 打印即将执行的指令
            echo "进入$MYSQL_DOCKER_CONTAINER_NAME容器: docker exec -it $MYSQL_DOCKER_CONTAINER_NAME  /bin/bash -c 'sh /etc/mysql/scripts/docker_mysql_db_init.sh'"
            # 进入容器并执行脚本：
            docker exec -it $MYSQL_DOCKER_CONTAINER_NAME  /bin/bash -c "sh /etc/mysql/scripts/docker_mysql_db_init.sh"
            if [[ $? -eq 0 ]]; then
                # 删除执行文件
                rm -f $MYSQL_DOCKER_PATH/scripts/docker_mysql_db_init.sh
                echo "$MYSQL_DOCKER_CONTAINER_NAME容器已创建完毕!"
            else
                echo "$MYSQL_DOCKER_CONTAINER_NAME容器创建数据库表时存在异常问题..."
                echo "尝试停止$MYSQL_DOCKER_CONTAINER_NAME容器..."
                docker stop $MYSQL_DOCKER_CONTAINER_NAME
                echo "尝试删除$MYSQL_DOCKER_CONTAINER_NAME容器..."
                docker rm $MYSQL_DOCKER_CONTAINER_NAME
                echo "尝试删除$MYSQL_DOCKER_CONTAINER_NAME容器...成功!"
                exit 1
            fi
        else
            echo "$MYSQL_DOCKER_PATH/scripts/docker_mysql_db_init.sh文件不存在，docker需要用此文件创建mysql容器实例并创建用户和数据库表."
            exit 1
        fi
    else
        echo "检查到$MYSQL_DOCKER_CONTAINER_NAME容器已创建!"
    fi
fi
# ===================启动或重启容器================================
if [[ $IS_EXISTS_MYSQL_CONTAINER == "true" && $IS_EXISTS_MYSQL_CONTAINER_RUNGING == "false" ]]; then
    echo "下面最多执行三次$MYSQL_DOCKER_CONTAINER_NAME容器检查重启..."
    while [[ $START_CONTAINER_CHECK_CURRENT -le $START_CONTAINER_CHECK_MAX_TIMES ]]; do
        echo "检查$MYSQL_DOCKER_CONTAINER_NAME容器状态......$START_CONTAINER_CHECK_CURRENT"
        for i in [ `docker ps ` ]; do
            if [[ "$i" == "$MYSQL_DOCKER_CONTAINER_NAME" ]]; then
                IS_EXISTS_MYSQL_CONTAINER_RUNGING="true"
                break
            fi
        done
        if [[ $IS_EXISTS_MYSQL_CONTAINER_RUNGING == "false" ]]; then
            echo "检查到$MYSQL_DOCKER_CONTAINER_NAME容器当前不在运行状态!"
            echo "启动$MYSQL_DOCKER_CONTAINER_NAME容器...."
            docker start $MYSQL_DOCKER_CONTAINER_NAME
            for i in [ `docker ps ` ]; do
                if [[ "$i" == "$MYSQL_DOCKER_CONTAINER_NAME" ]]; then
                    IS_EXISTS_MYSQL_CONTAINER_RUNGING="true"
                    break
                fi
            done
            if [[ $IS_EXISTS_MYSQL_CONTAINER_RUNGING == "true" ]]; then
                echo "$MYSQL_DOCKER_CONTAINER_NAME容器已经在运行!"
                break
            fi
        else
            echo "$MYSQL_DOCKER_CONTAINER_NAME容器已经在运行!"
            break
        fi
        START_CONTAINER_CHECK_CURRENT=$((START_CONTAINER_CHECK_CURRENT+1))
    done
    if [[ $IS_EXISTS_MYSQL_CONTAINER_RUNGING == "false" ]]; then
        echo "检查到$MYSQL_DOCKER_CONTAINER_NAME容器当前仍未运行,请联系相关人员进行处理!"
        exit 1
    fi
fi
#=============================升级处理==============================
if [[ $IS_EXISTS_MYSQL_CONTAINER == "true" && $IS_EXISTS_MYSQL_CONTAINER_RUNGING == "true" ]]; then
    if [[ -f "./docker_mysql_upgrade.sh" ]]; then
        echo "检查到MySQL升级脚本，即将执行....."
        cp docker_mysql_upgrade.sh $MYSQL_DOCKER_PATH/scripts/docker_mysql_upgrade.sh
        chmod a+x $MYSQL_DOCKER_PATH/scripts/docker_mysql_upgrade.sh
        echo "进入$MYSQL_DOCKER_CONTAINER_NAME容器执行升级脚本: docker exec -it $MYSQL_DOCKER_CONTAINER_NAME  /bin/bash -c 'sh /etc/mysql/scripts/docker_mysql_upgrade.sh'"
        # 进入容器并执行脚本：
        docker exec -it $MYSQL_DOCKER_CONTAINER_NAME  /bin/bash -c "sh /etc/mysql/scripts/docker_mysql_upgrade.sh"
        rm -f $MYSQL_DOCKER_PATH/scripts/docker_mysql_upgrade.sh
        echo "MySQL升级脚本(docker_mysql_upgrade.sh)，执行完毕!"
    fi
    echo "未检查到MySQL升级脚本(docker_mysql_upgrade.sh)，当前脚本$0执行完毕!"
fi
