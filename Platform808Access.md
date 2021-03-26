# RTVS与808平台对接说明
视频平台(以下简称RTVS)只负责与设备的音视频流通信，并不支持808通道接入，808通道需要808网关支持，RTVS与808网关通过以下方式进行通信。

RTVS自带的测试808网关已开源，可参考对应实现，地址：

[https://github.com/vanjoge/JT808GW](https://github.com/vanjoge/JT808GW)

[https://gitee.com/vanjoge/JT808GW](https://gitee.com/vanjoge/JT808GW)

|  功能   | 必须实现  |可能用到|
|  ----  | ----  | ----  |
| 实时视频  | [808指令](#808指令) | [0x9105实时音视频传输状态通知](#0x9105实时音视频传输状态通知)|
| 历史视频  |  [808指令](#808指令)<br>[录像列表应答](#录像列表应答) | [0x9105实时音视频传输状态通知](#0x9105实时音视频传输状态通知)<br>[设备音视频属性](#设备音视频属性)|
| 对讲  |  [808指令](#808指令) | [0x9105实时音视频传输状态通知](#0x9105实时音视频传输状态通知)<br>[设备音视频属性](#设备音视频属性)|
| 上级平台请求音视频  |  [时效口令](#时效口令) <br>[政府平台音音视频请求](#政府平台音音视频请求)<br>实时视频需实现接口<br>历史视频需实现接口|[网关通过HTTP获取视频GOV服务接口](#网关通过HTTP获取视频GOV服务接口) <br>[网关响应上级平台关闭实时音视频接口0x9802](#网关响应上级平台关闭实时音视频接口0x9802) <br>[网关响应上级平台远程录像控制接口0x9A02](#网关响应上级平台远程录像控制接口0x9A02)|


## 通过http接口交换的数据(RTVS请求)
* [808指令](#808指令)
* [0x9105实时音视频传输状态通知](#0x9105实时音视频传输状态通知)
* [根据车牌和车牌颜色获取手机号(已过时)](#根据车牌和车牌颜色获取手机号)

### 808指令
RTVS会按照以下规则通过Get请求发送0x9101、0x9201、0x9202、0x9205等1078规定走808通道指令，需要网关实现以下HTTP接口。

    [配置的网关HTTP接口地址]VideoControl?Content=808协议16进制字符串&IsSuperiorPlatformSend=是否是上级平台发送

    例1:http://127.0.0.1:8888/VideoControl?Content=9101001401377788321025C20C31302E31302E31302E3233304CF40000010001&IsSuperiorPlatformSend=true

    例2:http://127.0.0.1:8888/VideoControl?Content=920200090112464004260003030500200820172042

接口参数：

|  字段   | 说明  |例子|
|  ----  | ----  | ----  |
| Content  | 808协议16进制字符串(包头+包体)<br>包头不含7E、未转义、<b>流水号需要808平台替换</b>  | 9101001401377788321025C20C31302E31302E31302E3233304CF40000010001|
| IsSuperiorPlatformSend  | 是否是上级平台发送，网关可用此字段确定是否由上级平台发起。<br>一般为true才会包含此字段，为false时此字段不传 | true|

返回要求，类型String 值如下表：

|  消息ID   | 类型 | 返回数据  |
|  ----  | ----  | ----  |
| 0x9206   |String| 0：车辆不在线<br> -1：失败<br> 其他：应答流水号(下发9206指令的流水号) |
| 0x9201,0x9205 |String|  0：车辆不在线<br>  -1：失败<br> 其他：指令ID(redis接口中[录像列表应答](#录像列表应答)会用到此ID) | 
| 其他  |String|0：车辆不在线<br> -1：失败<br>  1：成功（仅指将指令成功发送到网关） | 


#### 网关接入处理逻辑
![gw](vsd/img/gw.png)

### 0x9105实时音视频传输状态通知
RTVS会按照以下规则通过Post请求批量发送0x9105通知，需要网关实现以下HTTP接口。

    [配置的网关HTTP接口地址]WCF0x9105?Content=命令帧信息

    例如:http://127.0.0.1:8888/WCF0x9105?Content=[{"Sim":"013777883221","NotifyList":[{"Channel":1,"PacketLossRate":0},{"Channel":2,"PacketLossRate":10}]},{"Sim":"013777883210","NotifyList":[{"Channel":1,"PacketLossRate":0}]}]


接口参数：

|  字段   | 说明  |例子|
|  ----  | ----  | ----  |
| Content  |[JT0x9105SimItem](#JT0x9105SimItem) <b>数组</b>的JSON  |[{"Sim":"013777883221","NotifyList":[{"Channel":1,"PacketLossRate":0},{"Channel":2,"PacketLossRate":10}]},{"Sim":"013777883210","NotifyList":[{"Channel":1,"PacketLossRate":0}]}] |

返回要求，类型String 值如下表：

 | 类型 | 返回数据  |
 | ----  | ----  |
|String|"-1"：失败<br>  "1"：成功（仅指将指令成功发送到网关） | 



#### JT0x9105SimItem
```
        /// <summary>
        /// cheji传输状态
        /// </summary>
        public class JT0x9105SimItem
        {
            /// <summary>
            /// 手机号
            /// </summary>
            [DataMember]
            public string Sim { get; set; }

            /// <summary>
            /// 通道信息
            /// </summary>
            [DataMember]
            public List<JT0x9105ChannelItem> NotifyList { get; set; }
        }


        /// <summary>
        /// 通道传输状态
        /// </summary>
        public class JT0x9105ChannelItem
        {
            /// <summary>
            /// 通道号
            /// </summary>
            [DataMember]
            public byte Channel { get; set; }

            /// <summary>
            /// 丢包率
            /// </summary>
            [DataMember]
            public byte PacketLossRate { get; set; }

        }
```


### 根据车牌和车牌颜色获取手机号

#### 可不实现此接口，已与上级平台Redis相关接口整合。

RTVS响应上级平台时，需要拿车牌和车牌颜色换取手机号，需要网关实现以下HTTP接口。


    [配置的网关HTTP接口地址]GetVehicleSim?PlateCode=[车牌号码]=&PlateColor=[车牌颜色]

    例如:http://127.0.0.1:8888/GetVehicleSim?PlateCode=京A12345=&PlateColor=2


接口参数：

|  字段   | 说明  |例子|
|  ----  | ----  | ----  |
| PlateCode  | 车牌号码  |京A12345|
| PlateColor  | 车牌颜色  | 2 |

返回要求：

    类型String，值 手机号，如果不存在返回 null或空字符串。
 
    

## 通过redis交换的数据
* [设备音视频属性](#设备音视频属性)
* [录像列表应答](#录像列表应答)
* [磁盘空间配置](#磁盘空间配置)
* [磁盘空间不足](#磁盘空间不足)
* [时效口令](#时效口令)
* [政府平台音音视频请求](#政府平台音音视频请求)
* [VDT转码MP4并FTP上传](#VDT转码MP4并FTP上传)
* [VDT转码完成](#VDT转码完成)
* [设备能力配置](#设备能力配置)


### 设备音视频属性
808平台需要在设备上线时候发送查询音视频属性指令，收到结果后将结果按照下面格式存入redis。

|  类别   | 值  |
|  ----  | ----  |
| 数据类型  | Hash |
| Key  | AVParameters:[手机号] |
| 值  | [JTRTAVParametersUpload](#JTRTAVParametersUpload)  |
| TTL  | -1  |

#### JTRTAVParametersUpload
```
    /// <summary>
    /// 终端上传音视频属性
    /// 0x1003
    /// </summary>
    [DataContract]
    public class JTRTAVParametersUpload
    {
        /// <summary>
        /// 输入音频编码方式（0：保留，1：G.721，2：G.722，3：G.723，4：G.728，5：G.729 ，......请参考JTRTAVCodeType）
        /// </summary>
        /// <remarks></remarks>
        [DataMember]
        public JTRTAVCodeType AudioCodeType { get; set; }
        /// <summary>
        /// 输入音频声道数
        /// </summary>
        /// <remarks></remarks>
        [DataMember]
        public byte AudioChannels { get; set; }
        /// <summary>
        /// 输入音频采样率（0:：8kHZ，1：22.05kHZ，2：44.1kHZ，3：48kHZ）
        /// </summary>
        /// <remarks></remarks>
        [DataMember]
        public JTRTAudioSampleRate AudioSamplingRate { get; set; }
        /// <summary>
        /// 输入音频采样位数（0:8位，1:16位，2:32位，请参考JTRTAudioSampleDigit）
        /// </summary>
        [DataMember]
        public JTRTAudioSampleDigit AudioSamplingDigit { set; get; }
        /// <summary>
        /// 音频帧长度(1至4294967295)
        /// </summary>
        [DataMember]
        public UInt16 AudioFrameLength { get; set; }
        /// <summary>
        /// 是否支持音频输出(0:不支持，1:支持)
        /// </summary>
        [DataMember]
        public byte AudioOut { get; set; }
        /// <summary>
        /// 视频编码方式（0：保留，1：G.721，2：G.722，3：G.723，4：G.728，5：G.729，......请参考JTRTAVCodeType）
        /// </summary>
        [DataMember]
        public JTRTAVCodeType VideoCodeType { get; set; }
        /// <summary>
        /// 终端支持的最大音频物理通道数量
        /// </summary>
        [DataMember]
        public byte AudioMaxChannels { get; set; }
        /// <summary>
        /// 终端支持的最大视频物理通道数量
        /// </summary>
        [DataMember]
        public byte VideoMaxChannels { get; set; }
    }
```

#### 实例
```bash
127.0.0.1:6379> HGETALL   AVParameters:013777883241
 1) "AudioChannels"
 2) "1"
 3) "AudioMaxChannels"
 4) "8"
 5) "AudioCodeType"
 6) "6"
 7) "AudioFrameLength"
 8) "320"
 9) "AudioOut"
10) "0"
11) "AudioSamplingDigit"
12) "1"
13) "AudioSamplingRate"
14) "0"
15) "VideoCodeType"
16) "98"
17) "VideoMaxChannels"
18) "8"
```

### 录像列表应答
RTVS向808平台发送查询录像列表指令后，808平台收到设备应答后，应当将应答结果按下面格式写入redis。

|  类别   | 值  |
|  ----  | ----  |
| 数据类型  | String |
| Key  | OCX_ORDERINFO_[发起指令时HTTP接口返回的指令ID] |
| 值  | [VideoOrderAck](#VideoOrderAck) 的JSON ,如果指令失败将VideoList置为null|
| TTL  | 建议为5分钟，即300  |

#### VideoOrderAck
```
    /// <summary>
    /// 视频指令应答消息
    /// </summary>
    public class VideoOrderAck
    {
        /// <summary>
        /// 返回值状态:0(初始)，1（成功）,2（设备不在线），3（失败），4（等待回应超时），5（等待回应中），6（作废）
        /// </summary>
        public int Status { get; set; }

        /// <summary>
        /// 录像列表
        /// </summary>
        public JTVideoListInfo VideoList { get; set; }

        /// <summary>
        /// 错误消息
        /// </summary>
        public string ErrMessage { get; set; }
    }
```
#### VideoOrderAck.java
```
public class VideoOrderAck {
    /**
     * 返回值状态:0(初始)，1（成功）,2（设备不在线），3（失败），4（等待回应超时），5（等待回应中），6（作废）
     */
    public int Status;

    /**
     * 录像列表
     */
    public JTVideoListInfo VideoList;

    /**
     * 错误消息
     */
    public String ErrMessage;

    // 已省略getset方法
}
```


#### JTVideoListInfo
```
    /// <summary>
    /// 终端上传音视频资源列表数据格式
    /// （0x1205）
    /// </summary>
    [DataContract]
    public class JTVideoListInfo 
    {
        /// <summary>
        /// 流水号（对应查询音视频资源列表指令的流水号）
        /// </summary>
        [DataMember]
        public UInt16 SerialNumber { get; set; }
        /// <summary>
        /// 音视频资源总数（无符合条件的音视频资源，置为0）
        /// </summary>
        [DataMember]
        public UInt32 FileCount { get; set; }
        /// <summary>
        /// 音视频资源列表（见表23）
        /// </summary>
        [DataMember]
        public List<JTVideoFileListItem> FileList { get; set; }

    }
    /// <summary>
    /// 终端上传音视频资源列表数据格式
    /// 终端上传音视频资源列表格式
    /// （0x1205）
    /// </summary>
    [DataContract]
    public class JTVideoFileListItem 
    {
        /// <summary>
        /// 逻辑通道号（0表示所有通道）
        /// </summary>
        [DataMember]
        public byte Channel { get; set; }
        /// <summary>
        /// 开始时间（yyyy-MM-dd HH:mm:ss）
        /// </summary>
        [DataMember]
        public DateTime StartTime { get; set; }
        /// <summary>
        /// 结束时间（yyyy-MM-dd HH:mm:ss）
        /// </summary>
        [DataMember]
        public DateTime EndTime { get; set; }
        /// <summary>
        /// 报警标志（bit0~bit31见JT/T 808-2011表18报警标志位定义；bit32~bit64见表13；全0表示无报警类型条件）
        /// </summary>
        [DataMember]
        public UInt64 Alarm { get; set; }
        /// <summary>
        /// 音视频资源类型（0：音视频，1：音频，2：视频，3：视频或音视频）
        /// </summary>
        [DataMember]
        public byte MediaType { get; set; }
        /// <summary>
        /// 码流类型（0：所有码流，1：主码流，2：子码流）
        /// </summary>
        [DataMember]
        public byte StreamType { get; set; }
        /// <summary>
        /// 存储器类型（0：所有存储器，1：主存储器，2：灾备存储器）
        /// </summary>
        [DataMember]
        public MemoryType StorageType { get; set; }
        /// <summary>
        /// 文件大小（单字节BYTE）
        /// </summary>
        [DataMember]
        public uint FileSize { get; set; }

    }
```
#### JTVideoListInfo.java 和 JTVideoFileListItem.java
```
public class JTVideoListInfo {
    /**
     * 流水号（对应查询音视频资源列表指令的流水号）
     */
    public int SerialNumber ;
    /**
     * 音视频资源总数（无符合条件的音视频资源，置为0）
     */
    public int FileCount ;
    /**
     * 音视频资源列表（见表23）
     */
    public List<JTVideoFileListItem> FileList ;

    // 已省略getset方法
}

public class JTVideoFileListItem {
    /**
     * 逻辑通道号（0表示所有通道）
     */
    public byte Channel ;

    /**
     * 开始时间（yyyy-MM-dd HH:mm:ss）
     */
    public String StartTime ;
    /**
     * 结束时间（yyyy-MM-dd HH:mm:ss）
     */
    public String EndTime ;
    /**
     * 报警标志（bit0~bit31见JT/T 808-2011表18报警标志位定义；bit32~bit64见表13；全0表示无报警类型条件）
     */
    public long Alarm ;
    /**
     * 音视频资源类型（0：音视频，1：音频，2：视频，3：视频或音视频）
     */
    public byte MediaType ;
    /**
     * 码流类型（0：所有码流，1：主码流，2：子码流）
     */
    public byte StreamType ;
    /**
     * 存储器类型（0：所有存储器，1：主存储器，2：灾备存储器）
     */
    public int StorageType ;
    /**
     * 文件大小（单字节BYTE）
     */
    public long FileSize ;

    // 已省略getset方法
}
```


#### 实例
```bash
127.0.0.1:6379> GET OCX_ORDERINFO_637469123220860199
"{\"Status\":1,\"VideoList\":{\"SerialNumber\":140,\"FileCount\":12,\"FileList\":[{\"Channel\":1,\"StartTime\":\"2021-01-22T00:00:00\",\"EndTime\":\"2021-01-22T00:05:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:05:00\",\"EndTime\":\"2021-01-22T00:10:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:10:00\",\"EndTime\":\"2021-01-22T00:15:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:15:00\",\"EndTime\":\"2021-01-22T00:20:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:20:00\",\"EndTime\":\"2021-01-22T00:25:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:25:00\",\"EndTime\":\"2021-01-22T00:30:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:30:00\",\"EndTime\":\"2021-01-22T00:35:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:35:00\",\"EndTime\":\"2021-01-22T00:40:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:40:00\",\"EndTime\":\"2021-01-22T00:45:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:45:00\",\"EndTime\":\"2021-01-22T00:50:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:50:00\",\"EndTime\":\"2021-01-22T00:55:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812},{\"Channel\":1,\"StartTime\":\"2021-01-22T00:55:00\",\"EndTime\":\"2021-01-22T01:00:00\",\"Alarm\":0,\"MediaType\":0,\"StreamType\":0,\"StorageType\":1,\"FileSize\":4938812}]},\"ErrMessage\":null}"
```

### 磁盘空间配置
此处按照1077功能要求配置磁盘空间使用规则，需要平台将配置写入redis，RTVS会按照配置的值进行磁盘空间管理。

|  类别   | 值  |
|  ----  | ----  |
| 数据类型  | Hash |
| Key  | storage_settings |
| 值  | [JTStorageSettings](#JTStorageSettings) |
| TTL  | -1  |
#### JTStorageSettings
```
        /// <summary>
        /// 磁盘设置
        /// </summary>
        [DataContract]
        public class JTStorageSettings
        {
            /// <summary>
            /// 超出阈值后处理  1 表示滚动删除 其他无动作
            /// </summary>
            [DataMember]
            public byte beyondFlag;

            /// <summary>
            /// 存储报警阈值0-100
            /// </summary>
            [DataMember]
            public int alarmThreshold;
        }
```


#### 实例
```bash
127.0.0.1:6379> HGETALL storage_settings
1) "beyondFlag"
2) "1"
3) "alarmThreshold"
4) "90"
```


### 磁盘空间不足
当磁盘空间超过设定上限百分比后，RTVS向Redis发布磁盘空间不足报警，平台需要订阅此消息显示报警。

|  类别   | 值  |
|  ----  | ----  |
| 类型  | Subscribe |
| Key  | not_enough_storage_space_channel |
| 值  | String |

### 时效口令
与政府平台交互的时效口令信息，需要平台在更新时写入redis

|  类别   | 值  |
|  ----  | ----  |
| 类型  | String |
| Key  | AUTHORIZE_CODE_1 或 AUTHORIZE_CODE_2 |
| 值  | String |
| TTL  | -1  |


AUTHORIZE_CODE_1 为 归属地区政府平台使用的时效口令

AUTHORIZE_CODE_2 为 跨域地区政府平台使用的时效口令

#### 实例
```bash
127.0.0.1:6379> GET AUTHORIZE_CODE_1
"aaa"
127.0.0.1:6379> GET AUTHORIZE_CODE_2
"bbb"
```

### 政府平台音音视频请求
政府平台音视频请求会先从809链路发送消息，网关返回服务器信息后政府平台才会请求视频流，RTVS收到的请求无法确认是实时还是历史，所以需要网关将其他信息写入redis中，格式如下：


#### 政府平台音实时音视频请求
|  类别   | 值  |
|  ----  | ----  |
| 类型  | String |
| Key  | [车牌号码].[车牌颜色].[逻辑通道号].[音视频标志]|
| 值  |real@[[JTSDownRealVideoRequest](#JTSDownRealVideoRequest) 的JSON]  |
| TTL  | 建议为5分钟，即300  |

##### JTSDownRealVideoRequest
```
    /// <summary>
    /// 实时音视频请求消息
    /// DOWN_REALVIDEO_MSG_STARTUP
    /// （0x9801）
    /// </summary>
    public class JTSDownRealVideoRequest
    {
        /// <summary>
        /// 音视频类型
        /// 0x00:音视频；0x01:音频；0x02:视频
        /// </summary>
        public byte AvitemType { get; set; }
        /// <summary>
        /// 手机号 如有不再调用http请求换取SIM接口
        /// </summary>
        public string Sim { get; set; }
    }
```

#### 实例
```bash
127.0.0.1:6379> GET 皖A12341.1.1.0
"real@{AvitemType:0,Sim:\"111111111111\"}"
```

#### 政府平台音历史音视频请求
|  类别   | 值  |
|  ----  | ----  |
| 类型  | String |
| Key  | [车牌号码].[车牌颜色].[逻辑通道号].[音视频标志]|
| 值  |back@[[JTRTDownPlayBackMsgStartUp](#JTRTDownPlayBackMsgStartUp) 的JSON]  |
| TTL  | 建议为5分钟，即300  |
##### JTRTDownPlayBackMsgStartUp
```
    /// <summary>
    /// 远程录像回放请求消息 
    /// 从链路   
    /// DOWN_PLAYBACK_MSG_STARTUP
    /// 0x9A01
    /// </summary>
    public class JTRTDownPlayBackMsgStartUp
    {
        /// <summary>
        /// 码流类型
        /// </summary>
        /// <remarks></remarks>
        public byte STREAM_TYPE { get; set; }
        /// <summary>
        /// 回放起始时间   UTC时间
        /// </summary>
        /// <remarks></remarks>
        public UInt64 PLAYBACK_STARTTIME { get; set; }
        /// <summary>
        /// 回放结束时间   UTC时间
        /// </summary>
        /// <remarks></remarks>
        public UInt64 PLAYBACK_ENDTIME { get; set; }
        /// <summary>
        /// 手机号 如有不再调用http换取SIM接口
        /// </summary>
        public string Sim { get; set; }
        /// <summary>
        /// 音视频类型
        /// 0x00:音视频；0x01:音频；0x02:视频；0x03:视频或音视频
        /// </summary>
        public byte AVITEM_TYPE { get; set; }
    }
```


#### 实例
```bash
127.0.0.1:6379> GET 皖A12341.1.3.0
"back@{\"AVITEM_TYPE\":0,\"STREAM_TYPE\":0,\"PLAYBACK_STARTTIME\":1611244800,\"PLAYBACK_ENDTIME\":1611248400,Sim:\"111111111111\"} "
```


#### 流程图
![gov](vsd/img/gov.png)

### VDT转码MP4并FTP上传
服务端视频缓存格式为VDT，RTVS支持将VDT格式文件转码成MP4并上传到指定FTP服务器。(与设备录像FTP上传逻辑一致)


|  类别   | 值  |
|  ----  | ----  |
| 类型  | Publish |
| Key  | transcode_mp4_upload_ftp_start |
| 值  | [TranscodeUploadStart](#TranscodeUploadStart) 的JSON|
```

    public class TranscodeUploadStart
    {
        /// <summary>
        /// 写redis的key值
        /// </summary>
        public string redis_key;
        /// <summary>
        /// 写redis的模式 0.string set 1.publish
        /// </summary>
        public int redis_mode;
        /// <summary>
        /// 自定义标记
        /// </summary>
        public string tag;
        /// <summary>
        /// 手机号
        /// </summary>
        public string sim;
        /// <summary>
        /// 通道号
        /// </summary>
        public byte channel;
        /// <summary>
        /// DateTimeToUNIX_long（格林威治时间）
        /// </summary>
        public long start_time;
        /// <summary>
        /// DateTimeToUNIX_long（格林威治时间）
        /// </summary>
        public long end_time;
        /// <summary>
        /// 字段含义同1078的0x1205
        /// </summary>
        public ulong alam;
        /// <summary>
        /// 字段含义同1078的0x1205
        /// </summary>
        public byte video_audio_type;
        /// <summary>
        /// 字段含义同1078的0x1205
        /// </summary>
        public byte stream_type;
        /// <summary>
        /// 字段含义同1078的0x1205
        /// </summary>
        public byte storage_type;
        /// <summary>
        /// ftp信息
        /// </summary>
        public string ftp_ip;

        public int ftp_port;

        public string ftp_username;

        public string ftp_password;

        public string ftp_remote_filename;

        public string ftp_remote_filepath;
    }
```

### VDT转码并FTP上传完成
RTVS转码MP4并上传FTP完成后，会通过TranscodeUploadStart指定的方式（redis_key 和 redis_mode）写回redis，平台需要按照对应方式取最终结果。


|  类别   | 值  |
|  ----  | ----  |
| 类型  | Subscribe 或 String 由 [TranscodeUploadStart.redis_mode]决定 |
| Key  | [TranscodeUploadStart指定的redis_key] |
| 值  | [TranscodeUploadFinish](#TranscodeUploadFinish) 的JSON|

#### TranscodeUploadFinish
```
  public class TranscodeUploadFinish
    {
        /// <summary>
        /// 自定义标记
        /// </summary>
        public string tag;
        /// <summary>
        /// //0成功, -2查询数据库失败 -3ftp上传失败
        /// </summary>
        public int error_code; 
    }
```

### 设备能力配置
此处主要是为了解决不同厂家设备实现不一致的问题，可按照设备配置对讲数据是否需要海思头，同时支持多少路实时或历史视频传输等。


|  类别   | 值  |
|  ----  | ----  |
| 类型  | String |
| Key  | SIM_CONFIG_FOR_RTVS_[手机号] |
| 值  | [SimLimiteConfig](#SimLimiteConfig) 的JSON|
| TTL  | -1  |
```
    /// <summary>
    /// 每个设备手机号一个配置
    /// </summary>
    public class SimLimiteConfig
    {
        /// <summary>
        /// 最大连接数
        /// </summary>
        public int m_sim_max_connection_all;
        /// <summary>
        /// 实时流最大连接数
        /// </summary>
        public int m_sim_max_connection_realplay;
        /// <summary>
        /// 回放流最大连接数
        /// </summary>
        public int m_sim_max_connection_backplay;
        /// <summary>
        /// 对讲流最大连接数
        /// </summary>
        public int m_sim_max_connection_talk;
        /// <summary>
        /// 广播最大连接数
        /// </summary>
        public int m_sim_max_connection_listen;

        /// <summary>
        /// 同一通道最大连接数
        /// </summary>
        public int m_channel_max_connection_all;
        /// <summary>
        /// 同一通道最大实时流连接数（区分主子码流能有2个）
        /// </summary>
        public int m_channel_max_connection_realplay;
        /// <summary>
        /// 同一通道回放流最大连接数
        /// </summary>
        public int m_channel_max_connection_backplay;
        /// <summary>
        /// 同一通道对讲流最大连接数
        /// </summary>
        public int m_channel_max_connection_talk;
        /// <summary>
        /// 同一通道广播最大连接数
        /// </summary>
        public int m_channel_max_connection_listen;

        /// <summary>
        /// 同一设备对讲监听能不能同时进行
        /// </summary>
        public bool m_is_taklback_listen_meanwhile;
        /// <summary>
        /// 同一通道实时历史能不能同时传
        /// </summary>
        public bool m_is_channel_real_back_meanwhile;
        /// <summary>
        /// 同一通道不同码流类型能不能同时传
        /// </summary>
        public bool m_is_channel_real_streamtype_meanwhile;

        /// <summary>
        /// 是否是绝对时间戳
        /// </summary>
        public bool m_is_absolute_timestamp;
        /// <summary>
        /// 绝对时间戳的起始时间
        /// </summary>
        public long m_start_absolute_timestamp;

        /// <summary>
        /// 是否有海思头
        /// </summary>
        public bool m_is_audio_have_haisi_header;

        /// <summary>
        /// 是否设备cheji，一个连接就只发一个通道的数据
        /// </summary>
        public static bool m_is_device_connection_single_channel = true;

        /// <summary>
        /// 设置默认配置信息
        /// </summary>
        /// <param name="config"></param>
        private static void DefaultConfig(SimLimiteConfig config)
        {
            config.m_sim_max_connection_all = 20;
            config.m_sim_max_connection_realplay = 20;
            config.m_sim_max_connection_backplay = 20;
            config.m_sim_max_connection_talk = 3;
            config.m_sim_max_connection_listen = 3;

            config.m_channel_max_connection_all = 20;
            config.m_channel_max_connection_realplay = 20;
            config.m_channel_max_connection_backplay = 20;
            config.m_channel_max_connection_talk = 3;
            config.m_channel_max_connection_listen = 3;

            config.m_is_taklback_listen_meanwhile = false;
            config.m_is_channel_real_back_meanwhile = true;
            config.m_is_channel_real_streamtype_meanwhile = true;

            config.m_is_absolute_timestamp = false;
            
            config.m_is_audio_have_haisi_header = true;
        }

    }
```


## RTVS提供的HTTP接口
### 网关通过HTTP获取视频GOV服务接口
网关在收到上级平台音视频请求后，需要应答视频服务器IP和端口，如果RTVS启用集群模式，需要网关通过集群管理API获取一个最佳视频GOV服务地址。

接口地址：

    [集群管理地址]api/GetBest?Type=1005&Tag=[手机号]
	
	Tag可传可不传，传Tag会尽量保证同一个设备在一个RTVS上，建议加上。

    例:http://127.0.0.1:30888/api/GetBest?Type=1005&Tag=013300001111


返回数据格式如下


    [IP地址]:[端口]

    例: 10.10.10.228:6035

### 网关响应上级平台关闭实时音视频接口0x9802
网关在收到上级平台关闭实时音视频请求后，可以不与RTVS交互直接发给设备，但可能造成正在观看的其他客户端也被关闭。

为解决此问题，可以将此指令转发给RTVS来处理关闭。

接口地址：

    [集群管理地址]ProxyTag/[Tag]/1004/WebService/Gov0x9802?VehicleNO=[车牌号]&VehicleColor=[车牌颜色]&ChannelID=[通道号]&AvitemType=[音视频类型]
	
	Tag与获取GOV服务地址的Tag保持一致。

    例:http://127.0.0.1:30888/ProxyTag/013300001111/1004/WebService/Gov0x9802?VehicleNO=京A12345&VehicleColor=2&ChannelID=1&AvitemType=0



接口参数 可查看1078协议中0x9802相关定义：

|  字段   | 说明  |例子|
|  ----  | ----  | ----  |
| Tag  | Tag与获取GOV服务地址的Tag保持一致，建议为手机号  |013300001111|
| VehicleNO  | 车牌号码  |京A12345|
| VehicleColor  | 车牌颜色  | 2 |
| ChannelID  | 逻辑通道号 0 表示所有  | 1 |
| AvitemType  | 音视频类型  0x00:音视频；0x01:音频；0x02:视频  | 0 |



返回数据格式如下


 | 返回值 | 说明  |
 | ----  | ----  |
|-1|参数错误 | 
|0|失败 | 
|1|成功 | 


### 网关响应上级平台远程录像控制接口0x9A02

接口地址：

    [集群管理地址]ProxyTag/[Tag]/1004/WebService/Gov0x9A02?VehicleNO=[车牌号]&VehicleColor=[车牌颜色]&ControlType=[控制类型]&FastTime=[倍数]&DateTime=[拖动位置]
	
	Tag与获取GOV服务地址的Tag保持一致。

    例:http://127.0.0.1:30888/ProxyTag/013300001111/1004/WebService/Gov0x9A02?VehicleNO=京A12345&VehicleColor=2&ControlType=5&FastTime=0&DateTime=1606905169



接口参数 可查看1078协议中0x9A02相关定义：

|  字段   | 说明  |例子|
|  ----  | ----  | ----  |
| Tag  | Tag与获取GOV服务地址的Tag保持一致，建议为手机号  |013300001111|
| VehicleNO  | 车牌号码  |京A12345|
| VehicleColor  | 车牌颜色  | 2 |
| ControlType  | 回放类型<br> 0x00:正常回放,0x01:暂停回放,0x02:结束回放,0x03:快进回放,0x04:关键帧快退回放,0x05:拖动回放,0x06:关键帧播放  | 5 |
| FastTime  | 快进或快退倍数 回放类型为0x3或0x4时有效<br> 0x00:无效,0x01:1倍,0x02:2倍,0x03:4倍,0x04:8倍,0x05:16倍  | 0 |
| DateTime  | 拖动位置，用UTC时间表示，回放控制为0x05时，此字段内容有效    | 1606905169 |



返回数据格式如下


 | 返回值 | 说明  |
 | ----  | ----  |
|-1|参数错误 | 
|0|失败 | 
|1|成功 | 

