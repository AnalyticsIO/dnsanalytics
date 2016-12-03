#!/bin/bash
# This install file pulls & installs elasticsearch and kibana

VOL=$HOME/PERSIST

mkdir -p $VOL

cp -vr setup-res/elasticsearch $VOL
cp -vr setup-res/kibana $VOL
cp -vr setup-res/packetbeat $VOL

OUT=$?
if [ $OUT -ne 0 ];then
   exit 1;
fi

docker pull elasticsearch:5
docker pull kibana:5
docker pull ghoranyi/docker-agent-pb

docker stop kibana
docker stop packetbeat
docker stop elasticsearch

docker rm elasticsearch
docker rm kibana
docker rm packetbeat

docker run -d -p 9200:9200 -p 9300:9300 --name elasticsearch -v "$VOL/elasticsearch/config":/usr/share/elasticsearch/config -v "$VOL/elasticsearch/data":/usr/share/elasticsearch/data elasticsearch:5
docker run -d -p 5601:5601 --name kibana --link elasticsearch:elasticsearch -e ELASTICSEARCH_URL=http://elasticsearch:9200 kibana:5
docker run -d --network=host --name packetbeat -v "$VOL/packetbeat":/etc/packetbeat ghoranyi/docker-agent-pb

