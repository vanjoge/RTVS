
# CDVR

Base URLs:

* address : http://server_ip:30889


# Record

## GET /Record/Start

GET /Record/Start

### Params

|Name|Location|Type|Required|Description|
|---|---|---|---|---|
|Sim|query|string| no |none|
|Channel|query|string| no |none|
|Protocol|query|integer| no |none|

> Response Examples

> 200 Response

```json
{
  "result": 0,
  "resultNote": "string",
  "detail": "string"
}
```

### Responses

|HTTP Status Code |Meaning|Description|Data schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Success|[RecordRet](#schemarecordret)|

## GET /Record/Stop

GET /Record/Stop

### Params

|Name|Location|Type|Required|Description|
|---|---|---|---|---|
|Sim|query|string| no |none|
|Channel|query|string| no |none|
|Protocol|query|integer| no |none|

> Response Examples

> 200 Response

```json
{
  "result": 0,
  "resultNote": "string",
  "detail": "string"
}
```

### Responses

|HTTP Status Code |Meaning|Description|Data schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Success|[RecordRet](#schemarecordret)|

## POST /Record/BatchStart

POST /Record/BatchStart or /Record/Open

> Body Parameters

```json
[
  {
    "sim": "string",
    "channel": [
      "string"
    ],
    "protocol": 0
  }
]
```

### Params

|Name|Location|Type|Required|Description|
|---|---|---|---|---|
|body|body|[DeviceInfo](#schemadeviceinfo)| no |none|

> Response Examples

> 200 Response

```json
{
  "result": 0,
  "resultNote": "string",
  "detail": "string"
}
```

### Responses

|HTTP Status Code |Meaning|Description|Data schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Success|[RecordRet](#schemarecordret)|


## POST /Record/BatchStop

POST /Record/BatchStop or /Record/Close

> Body Parameters

```json
[
  {
    "sim": "string",
    "channel": [
      "string"
    ],
    "protocol": 0
  }
]
```

### Params

|Name|Location|Type|Required|Description|
|---|---|---|---|---|
|body|body|[DeviceInfo](#schemadeviceinfo)| no |none|

> Response Examples

> 200 Response

```json
{
  "result": 0,
  "resultNote": "string",
  "detail": "string"
}
```

### Responses

|HTTP Status Code |Meaning|Description|Data schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Success|[RecordRet](#schemarecordret)|

## POST /Record/QueryVideoFiles

POST /Record/QueryVideoFiles

> Body Parameters

```json
{
  "timeStart": "string",
  "timeEnd": "string",
  "devices": [
    {
      "sim": "string",
      "channel": [
        "string"
      ],
      "protocol": 0
    }
  ]
}
```

### Params

|Name|Location|Type|Required|Description|
|---|---|---|---|---|
|body|body|[QueryDevicesVideoFiles](#schemaquerydevicesvideofiles)| no |none|

> Response Examples

> 200 Response

```json
"string"
```

### Responses

|HTTP Status Code |Meaning|Description|Data schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Success|string|
