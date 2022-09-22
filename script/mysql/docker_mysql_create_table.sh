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


####GBS
mysql_gbs_dbname="gbs"

#创建GBS数据库
sql_create_database="CREATE DATABASE IF NOT EXISTS $mysql_gbs_dbname"
mysql -u$mysql_root_user_name -p$mysql_root_user_pwd -P$mysql_port -e"$sql_create_database"

#创建表
sql_create_table="USE $mysql_gbs_dbname;
CREATE TABLE IF NOT EXISTS T_Catalog (
  ChannelID varchar(50) NOT NULL COMMENT 'CatalogID',
  DeviceID varchar(50) NOT NULL COMMENT '设备ID',
  ParentID varchar(50) NOT NULL COMMENT '上级ID',
  Name varchar(50) NOT NULL COMMENT '设备/区域/系统名称',
  Manufacturer varchar(50) NOT NULL DEFAULT '' COMMENT '当为设备时，设备厂商',
  Model varchar(50) NOT NULL DEFAULT '' COMMENT '当为设备时，设备型号',
  Owner varchar(50) NOT NULL DEFAULT '' COMMENT '当为设备时，设备归属',
  CivilCode varchar(50) NOT NULL DEFAULT '' COMMENT '行政区域',
  Block varchar(50) NOT NULL DEFAULT '' COMMENT '警区',
  Address varchar(50) NOT NULL DEFAULT '' COMMENT '当为设备时，安装地址',
  Parental bit(1) NOT NULL COMMENT '当为设备时，是否有子设备(必选)， 1有 0没有',
  BusinessGroupID varchar(50) NOT NULL DEFAULT '' COMMENT '虚拟分组ID',
  SafetyWay int(11) NOT NULL DEFAULT '0' COMMENT '信令安全模式(可选)缺省为0； 0：不采用 2：S/MIME签名方式 3：S/MIME加密签名同时采用方式 4：数字摘要方式',
  RegisterWay int(11) NOT NULL DEFAULT '1' COMMENT '注册方式(必选)缺省为1； 1:符合IETF FRC 3261标准的认证注册模式； 2:基于口令的双向认证注册模式； 3:基于数字证书的双向认证注册模式；',
  CertNum varchar(50) NOT NULL DEFAULT '' COMMENT '证书序列号',
  Certifiable bit(1) NOT NULL COMMENT '证书有效标志(有证书的设备必选)， 0无效 1有效',
  ErrCode int(11) NOT NULL DEFAULT '0' COMMENT '无效原因码',
  EndTime timestamp NULL DEFAULT NULL COMMENT '证书终止有效期',
  Secrecy bit(1) NOT NULL COMMENT '保密属性(必选) 0：不涉密 1涉密',
  IPAddress varchar(50) NOT NULL DEFAULT '' COMMENT '设备/区域/系统IP地址',
  Port int(11) NOT NULL DEFAULT '0' COMMENT '设备/区域/系统端口',
  Password varchar(255) NOT NULL DEFAULT '' COMMENT '设备口令',
  Status varchar(50) NOT NULL COMMENT '设备状态',
  Longitude double NOT NULL COMMENT '经度',
  Latitude double NOT NULL COMMENT '纬度',
  RemoteEP varchar(50) NOT NULL DEFAULT '' COMMENT '远程设备终结点',
  Online bit(1) NOT NULL DEFAULT b'1' COMMENT '在线状态',
  OnlineTime timestamp NOT NULL DEFAULT '2000-01-01 00:00:00' COMMENT '上次上线时间',
  OfflineTime timestamp NULL DEFAULT NULL COMMENT '离线时间',
  PRIMARY KEY (ChannelID,DeviceID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS T_DeviceInfo (
  DeviceID varchar(50) NOT NULL COMMENT '设备ID',
  DeviceName varchar(50) DEFAULT NULL COMMENT '目标设备/区域/系统的名称(可选)',
  Manufacturer varchar(50) DEFAULT NULL COMMENT '设备生产商(可选)',
  Model varchar(50) DEFAULT NULL COMMENT '设备型号(可选)',
  Firmware varchar(100) DEFAULT NULL COMMENT '设备固件版本(可选)',
  Channel int(11) NOT NULL COMMENT '视频输入通道数(可选)',
  Reported bit(1) NOT NULL DEFAULT b'0' COMMENT '设备上报过DEVICEINFO',
  CatalogChannel int(11) NOT NULL DEFAULT '0' COMMENT 'Catalog上报视频通道数',
  GetCatalogTime timestamp NULL DEFAULT NULL COMMENT '上次获取Catalog时间',
  Online bit(1) NOT NULL DEFAULT b'0' COMMENT '在线状态',
  OnlineTime timestamp NOT NULL DEFAULT '2000-01-01 00:00:00' COMMENT '上次上线时间',
  KeepAliveTime timestamp NOT NULL DEFAULT '2000-01-01 00:00:00' COMMENT '上次心跳时间',
  OfflineTime timestamp NULL DEFAULT NULL COMMENT '离线时间',
  RemoteInfo varchar(100) NOT NULL DEFAULT '' COMMENT '远端连接信息',
  DsOnline varchar(50) DEFAULT NULL COMMENT '是否在线(状态查询应答)',
  DsStatus varchar(50) DEFAULT NULL COMMENT '是否正常工作(状态查询应答)',
  DsReason varchar(50) DEFAULT NULL COMMENT '不正常工作原因',
  DsEncode varchar(50) DEFAULT NULL COMMENT '是否编码',
  DsRecord varchar(50) DEFAULT NULL COMMENT '是否录像',
  DsDeviceTime varchar(50) DEFAULT NULL COMMENT '设备时间和日期',
  GetDsTime timestamp NULL DEFAULT NULL COMMENT '上次设备状态信息查询应答时间',
  HasAlarm bit(1) NOT NULL DEFAULT b'0' COMMENT '是否有报警',
  CreateTime timestamp NOT NULL DEFAULT '2000-01-01 00:00:00' COMMENT '创建时间',
  UpTime timestamp NOT NULL DEFAULT '2000-01-01 00:00:00' COMMENT '更新时间',
  NickName varchar(255) NOT NULL DEFAULT '' COMMENT '别名',
  SubscribeExpires int(11) NOT NULL DEFAULT '0' COMMENT '目录订阅有效期',
  PRIMARY KEY (DeviceID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS T_Event (
  RowID bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  ChannelID varchar(50) NOT NULL COMMENT 'CatalogID',
  DeviceID varchar(50) NOT NULL COMMENT '设备ID',
  Event int(11) NOT NULL DEFAULT '0' COMMENT '状态改变事件 0-ON:上线,1-OFF:离线,2-VLOST:视频丢失,3-DEFECT:故障,4-ADD:增加,5-DEL:删除,6-UPDATE:更新',
  EventTime timestamp NOT NULL DEFAULT '2000-01-01 00:00:00' COMMENT '事件时间',
  PRIMARY KEY (RowID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS T_SuperiorInfo (
  Enable bit(1) NOT NULL COMMENT '启用',
  ID varchar(50) NOT NULL COMMENT '唯一ID',
  Name varchar(50) NOT NULL COMMENT '名称',
  ServerID varchar(50) NOT NULL COMMENT '上级国标编码',
  Server varchar(50) NOT NULL COMMENT '上级IP/域名',
  ServerPort int(11) NOT NULL COMMENT '上级端口',
  ClientID varchar(50) NOT NULL COMMENT '本地SIP国标编码',
  ClientName varchar(50) NOT NULL COMMENT '本地SIP名称',
  SIPUsername varchar(50) NOT NULL COMMENT 'SIP认证用户名',
  SIPPassword varchar(50) NOT NULL COMMENT 'SIP认证密码',
  Expiry int(11) NOT NULL COMMENT '注册有效期',
  RegSec int(11) NOT NULL COMMENT '注册间隔',
  HeartSec int(11) NOT NULL COMMENT '心跳周期',
  HeartTimeoutTimes int(11) NOT NULL COMMENT '最大心跳超时次数',
  UseTcp bit(1) NOT NULL COMMENT 'TCP/UDP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS T_UserInfo (
  Id int(11) NOT NULL,
  Name varchar(50) NOT NULL DEFAULT '' COMMENT '姓名',
  Username varchar(50) NOT NULL COMMENT '用户名',
  Password varchar(50) NOT NULL COMMENT '密码',
  Psalt varchar(50) NOT NULL DEFAULT '' COMMENT '加密盐',
  NickName varchar(100) NOT NULL DEFAULT '' COMMENT '昵称',
  HeadImg varchar(255) NOT NULL DEFAULT '' COMMENT '头像',
  LoginIp varchar(50) NOT NULL DEFAULT '' COMMENT '登录IP',
  Email varchar(50) NOT NULL DEFAULT '',
  Phone varchar(20) NOT NULL DEFAULT '',
  Remark varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  Status int(11) NOT NULL COMMENT '状态',
  DepartmentId int(11) NOT NULL COMMENT '部门ID',
  DepartmentName varchar(50) NOT NULL DEFAULT '' COMMENT '部门名称',
  CreateTime timestamp NOT NULL DEFAULT '2000-01-01 00:00:00' COMMENT '创建时间',
  UpTime timestamp NOT NULL DEFAULT '2000-01-01 00:00:00' COMMENT '更新时间',
  PRIMARY KEY (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
"

mysql -u$mysql_root_user_name -p$mysql_root_user_pwd  -P$mysql_port -e"$sql_create_table"