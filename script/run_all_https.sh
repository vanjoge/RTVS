#! /bin/bash


#以下为HTTPS时需要的证书配置，如果不需HTTPS，可以忽略
#H5对讲必须HTTPS  集群管理需要pfx证书
#设置服务器域名，用于HTTPS和防止某些IDC对未备案IP拦截，如果不设置则取IPADDRESS值。
export BeianAddress=(Your domain)

#CV_PFX_PATH pfx证书路径 (建议为绝对路径 如 /pem/xxx.com.pfx) 1.3.8之后可不配置，只用pem证书即可
#export CV_PFX_PATH=(Your pfx file path)

#CV_PFX_PWD pfx证书密码 1.3.8之后可不配置，只用pem证书即可
#export CV_PFX_PWD=(Your pfx password)

#CV_PEM_PATH pem证书路径 一般为*.crt或*.pem (建议为绝对路径 如 /pem/xxx.com.pem)
export CV_PEM_PATH=(Your pem file path)

#CV_PEMKEY_PATH pem证书私钥路径 一般为*.pem或*.key (建议为绝对路径 如 /pem/xxx.com.key)
export CV_PEMKEY_PATH=(Your pem key file path)


./run_all.sh