#!/bin/bash
docker-compose up -d
./create-ns-shard-cluster.sh
#docker-compose exec loader /app/loader/shell/sales.sh
