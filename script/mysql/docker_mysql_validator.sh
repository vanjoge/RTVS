#! /bin/bash
echo "当前执行文件......$0"
docker_mysql_remote_user_name="rtvsweb"
docker_mysql_remote_user_pwd="rtvs2018"
echo "Docker Mysql已创建远程登录用户:$docker_mysql_remote_user_name ,密码:$docker_mysql_remote_user_pwd"

echo "当前存在的数据库列表:"
mysql -u$docker_mysql_remote_user_name -p$docker_mysql_remote_user_pwd -e "show databases"

echo "查看数据库表:"
mysql -u$docker_mysql_remote_user_name -p$docker_mysql_remote_user_pwd -e "select table_name from information_schema.tables where table_schema='filecache' and table_type='base table'"
