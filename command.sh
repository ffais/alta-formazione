#!/bin/bash
export DOCKER_BUILDKIT=1
docker build -f Dockerfile-experimental -t registry .
docker build -t catalog .
docker built -t purchase .
docker built -t registry .
docker built -t zuul-proxy

docker create network altaformazione

docker run --network altaformazione --name zipkin -p 9411:9411 -d openzipkin/zipkin
docker run --network altaformazione --name mongo -d mongo:latest
docker run --memory 256m --network altaformazione -p 8761:8761 --name registry -d registry
docker run --network altaformazione --memory 256m --name catalog -p 18080:8080 -e "MONGO_URL=mongo" -e "ZIPKIN_URL=http://zipkin:9411" -e "EUREKA_URL=http://registry:8761/eureka" -d catalog
docker run --network altaformazione --memory 256m --name purchase -p 28080:8080 -e "MONGO_URL=mongo" -e "ZIPKIN_URL=http://zipkin:9411" -e "EUREKA_URL=http://registry:8761/eureka" -d purchase
docker run --network altaformazione --memory 256m --name zuul-proxy -p 5000:5000 -e "ZIPKIN_URL=http://zipkin:9411" -e "EUREKA_URL=http://registry:8761/eureka" -d zuul-proxy


docker exec -it catalog sh
docker logs -f catalog
docker rm -f catalog

docker-compose up -d
docker-compose down

docker-machine create node1
docker-machine ssh node1

docker stack deploy -c docker-compose.yaml altaf
docker stack rm altaf

declare -i i;i=0; while true; do i+=1; echo $i; curl -X GET -H "Content-Type: application/json" 'http://catalogo.local/api/products'; echo ""; sleep 2; done;
