#！/bin/bash
echo "当前执行文件......$0"
INFLUXDB_DATABASE_NAME="rtvsweb"
INFLUXDB_USER_NAME="admin"
INFLUXDB_USER_PWD="admin"
# influxdb数据库相关配置
echo "influxdb数据库相关配置"
influx -version
# 查询数据库列表
echo "查询数据库列表"
influx  -execute "show databases"
# 删除数据库
echo "删除数据库$INFLUXDB_DATABASE_NAME"
influx  -execute "drop database $INFLUXDB_DATABASE_NAME"
# 创建数据库
echo "创建数据库$INFLUXDB_DATABASE_NAME"
influx  -execute "create database $INFLUXDB_DATABASE_NAME"
# 创建用户并授权
echo "创建$INFLUXDB_USER_NAME用户并授权"
influx -execute "create user "$INFLUXDB_USER_NAME" with password '$INFLUXDB_USER_PWD' with all privileges"
# 查询用户列表
echo "查询用户列表"
influx -execute "use $INFLUXDB_DATABASE_NAME" -execute  "show users"
# 创建数据保存策略
echo "创建数据保存策略"
influx -execute "use $INFLUXDB_DATABASE_NAME" -execute  "CREATE RETENTION POLICY "rp_policy" ON "$INFLUXDB_DATABASE_NAME" DURATION 20d REPLICATION 1 DEFAULT"
# 查询数据保存策略
echo "查询数据保存策略"
influx -execute  "SHOW RETENTION POLICIES ON $INFLUXDB_DATABASE_NAME"



