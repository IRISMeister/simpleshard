#!/bin/bash
docker-compose -f docker-compose.yml -f docker-compose-pri2021.yml up -d
./create-ns-shard-cluster.sh

# You have to change "target.namespace=USER" of sales.conf before running this
#docker-compose -f docker-compose.yml -f docker-compose-pri2021.yml exec loader /app/loader/shell/sales.sh
