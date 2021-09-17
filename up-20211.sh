#!/bin/bash
docker-compose -f docker-compose.yml -f docker-compose-20211.yml up -d
./create-shard-cluster.sh
docker-compose -f docker-compose.yml -f docker-compose-20211.yml exec loader /app/loader/shell/sales.sh
# calendar table for ActiveAnalytics 
docker-compose -f docker-compose.yml -f docker-compose-20211.yml exec loader /app/loader/shell/dataexport.sh
