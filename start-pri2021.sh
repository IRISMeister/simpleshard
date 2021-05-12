#!/bin/bash
docker-compose -f docker-compose.yml -f docker-compose-pri2021.yml up -d
./create-shard-cluster.sh
docker-compose -f docker-compose.yml -f docker-compose-pri2021.yml exec loader /app/loader/shell/sales.sh
