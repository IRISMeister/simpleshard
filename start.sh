#!/bin/bash
docker-compose up -d
./create-shard-cluster.sh
docker-compose exec loader /app/loader/shell/sales.sh
