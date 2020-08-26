#！/bin/bash
echo "当前执行文件......$0"
# Mysql数据库相关配置
mysql_host="localhost"
mysql_port="3306"
mysql_database_name="filecache"
mysql_root_user_name="root"
mysql_root_user_pwd="root"
# 进入mysql控制台 默认用户是root
echo "Docker 表创建检查...."
#用户创建Mysql数据库脚本
echo "Docker Mysql控制台创建数据库表.... "
################创建表##################
sql_create_table="USE $mysql_database_name;
CREATE TABLE IF NOT EXISTS AVINFO (
  F_ID varchar(255) NOT NULL,
  F_SIM varchar(20) NOT NULL,
  F_CHANNEL int(11) NOT NULL,
  F_ALARM decimal(18,0) NOT NULL,
  F_STORAGE_TYPE int(11) NOT NULL,
  F_STREAM_TYPE int(11) NOT NULL,
  F_START_TIME decimal(20,0) NOT NULL,
  F_END_TIME decimal(20,0) NOT NULL,
  F_FILE_PATH varchar(255) NOT NULL,
  F_FILE_SIZE decimal(18,0) NOT NULL,
  F_DATA_TYPE int(11) default NULL,
  PRIMARY KEY (F_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS jt_log_flow (
  F_ID int(11) NOT NULL AUTO_INCREMENT,
  F_FD_TYPE varchar(45) NOT NULL,
  F_BS_TYPE varchar(45) NOT NULL,
  F_TIME bigint(20) NOT NULL,
  F_GUID_KEY varchar(45) DEFAULT NULL,
  F_EXPLAIN varchar(100) NOT NULL,
  F_DESCRIBLE varchar(1000) DEFAULT NULL,
  PRIMARY KEY (F_ID)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS jt_log_index (
  F_ID int(11) NOT NULL AUTO_INCREMENT,
  F_GUID_KEY varchar(45) NOT NULL,
  F_FD_TYPE varchar(45) NOT NULL,
  F_BS_TYPE varchar(45) NOT NULL,
  F_SIM varchar(45) NOT NULL,
  F_CHANNEL int(11) NOT NULL,
  F_IP varchar(45) NOT NULL,
  F_PORT int(11) NOT NULL,
  F_TIME bigint(20) NOT NULL,
  PRIMARY KEY (F_ID,F_GUID_KEY)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 ;
"
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd  -P$mysql_port -e"$sql_create_table"
#########################################
###########修改表结构，插入列############2019.2.21
echo "是否插入列...."
sql_columns_is_exits="USE $mysql_database_name; 
select 1 from information_schema.columns where table_name='jt_log_index' and column_name = 'F_ADDED_CONTEXT1';"
host=$(mysql -u$mysql_root_user_name -p$mysql_root_user_pwd  -P$mysql_port -e"$sql_columns_is_exits")
if [ ! -n "$host" ] ;then
	echo "插入列"
	sql_columns_insert="USE $mysql_database_name;
	ALTER TABLE jt_log_index 
	ADD COLUMN F_ADDED_CONTEXT1 VARCHAR(100) NULL AFTER F_TIME,
	ADD COLUMN F_ADDED_TIME1 BIGINT(20) NULL AFTER F_ADDED_CONTEXT1,
	ADD COLUMN F_ADDED_CONTEXT2 VARCHAR(100) NULL AFTER F_ADDED_TIME1,
	ADD COLUMN F_ADDED_TIME2 BIGINT(20) NULL AFTER F_ADDED_CONTEXT2,
	ADD COLUMN F_ADDED_CONTEXT3 VARCHAR(100) NULL AFTER F_ADDED_TIME2,
	ADD COLUMN F_ADDED_TIME3 BIGINT(20) NULL AFTER F_ADDED_CONTEXT3;"
	mysql -u$mysql_root_user_name -p$mysql_root_user_pwd  -P$mysql_port -e"$sql_columns_insert"
else
	echo "列已存在"
fi
##########################################
