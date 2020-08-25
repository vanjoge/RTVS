#! /bin/bash

DOCKER_ETH="dokcer0"

DOCKER_NETWORK="cvnetwork"
DOCKER_NETWORK_IPA="172.29.108.0/24"
DOCKER_NETWORK_IPGW="172.29.108.1/24"




function docker_create_network(){
    #判断NETWORK是否已经存在
    docker_network_exists $DOCKER_NETWORK $DOCKER_NETWORK_IPA
    if [[ $? -eq 0 ]]; then
        echo "创建docker自定义网络 $DOCKER_NETWORK $DOCKER_NETWORK_IPA"
		docker network rm $DOCKER_NETWORK
		
		docker network create --subnet=$DOCKER_NETWORK_IPA $DOCKER_NETWORK
        
        return 0
    fi
}
function docker_network_exists(){
    for i in [ `docker network inspect $1 --format='{{(index .IPAM.Config 0).Subnet}}'` ]; do
        if [[ "$i" == "$2" ]]; then
            return 1;
        fi
    done
    return 0;
}


docker_create_network

DOCKER_ETH=` ip addr |grep $DOCKER_NETWORK_IPGW|awk '{print $NF}'`


nmcli connection modify $DOCKER_ETH connection.zone trusted

systemctl stop NetworkManager.service

firewall-cmd --permanent --zone=trusted --change-interface=$DOCKER_ETH

systemctl start NetworkManager.service

nmcli connection modify $DOCKER_ETH connection.zone trusted

systemctl restart docker.service