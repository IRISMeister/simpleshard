#!/bin/bash
docker-compose exec data-0 iris session iris -U IRISDM export

docker-compose exec loader /app/loader/shell/master_table.sh
docker-compose exec loader /app/loader/shell/tx_table_main.sh
docker-compose exec loader /app/loader/shell/tx_table_sub1.sh
docker-compose exec loader /app/loader/shell/tx_table_sub2.sh

docker-compose exec data-0 iris session iris -U IRISDM tunetables
