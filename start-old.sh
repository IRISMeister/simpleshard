#!/bin/bash
docker-compose -f docker-compose.yml -f docker-compose-old.yml up -d
./create-shard-cluster.sh
docker-compose exec loader /app/loader/shell/sales.sh
