#！/bin/bash
echo "当前执行文件......$0"
# Mysql数据库相关配置
mysql_host="localhost"
mysql_port="3306"
mysql_database_name="filecache"
mysql_root_user_name="root"
mysql_root_user_pwd="root"
mysql_remote_user_name="rtvsweb"
mysql_remote_user_pwd="rtvs2018"
# 数据库表名大写与程序一致
mysql_table_name="AVINFO";
# 进入mysql控制台 默认用户是root
echo "Docker Mysql控制台创建数据库...."
# 为root用户设置密码
echo "Docker Mysql控制台为root用户设置密码....$mysql_root_user_pwd"
sql_alter_user="ALTER USER '$mysql_root_user_name'@'$mysql_host' IDENTIFIED BY '$mysql_root_user_pwd'"
# 防止新版本-e 密码设置不成功
mysql -u$mysql_root_user_name -e"$sql_alter_user" 2>/dev/null
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd -P$mysql_port -e"$sql_alter_user"

#删除可能重复的远程用户
echo "Docker Mysql控制台删除可能重复的远程用户....$mysql_remote_user_name"
sql_create_user="DROP USER '$mysql_remote_user_name'@'%' "
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd -P$mysql_port -e"$sql_create_user" 2>/dev/null

# 刷新数据库权限
echo "Docker Mysql刷新用户权限...."
sql_flush_privileges="flush privileges"
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd -P$mysql_port -e"$sql_flush_privileges"

# 添加远程登录用户
echo "Docker Mysql控制台创建远程用户....$mysql_remote_user_name"
sql_create_user="CREATE USER '$mysql_remote_user_name'@'%' IDENTIFIED WITH mysql_native_password BY '$mysql_remote_user_pwd'"
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd -P$mysql_port -e"$sql_create_user"

#为远程账号添加权限
echo "Docker Mysql控制台为远程账号添加权限.... *.* TO '$mysql_remote_user_name'@'%'"
sql_grant_user="GRANT ALL PRIVILEGES ON *.* TO '$mysql_remote_user_name'@'%'"
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd -P$mysql_port -e"$sql_grant_user"

# 创建数据库
echo "Docker Mysql控制台创建数据库.... $mysql_database_name"
sql_create_database="CREATE DATABASE IF NOT EXISTS $mysql_database_name"
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd -P$mysql_port -e"$sql_create_database"

# 刷新数据库权限
echo "Docker Mysql刷新用户权限...."
sql_flush_privileges="flush privileges"
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd -P$mysql_port -e"$sql_flush_privileges"

# 确定使用的数据库
echo "Docker Mysql确定使用的数据库....$mysql_database_name"
sql_select_use_db="USE $mysql_database_name"
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd -P$mysql_port -e"$sql_select_use_db"
