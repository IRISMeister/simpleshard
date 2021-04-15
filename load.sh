#!/bin/bash
docker-compose exec loader /app/loader/shell/master_table.sh
docker-compose exec loader /app/loader/shell/tx_table_main.sh
docker-compose exec loader /app/loader/shell/tx_table_sub1.sh
docker-compose exec loader /app/loader/shell/tx_table_sub2.sh

