#!/bin/bash -e
docker-compose exec -T data-0 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T data-1 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T data-2 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"

docker-compose exec data-0 bash -c "iris session iris -U %SYS < /home/irisowner/misc/enableshard.cos"
docker-compose exec data-1 bash -c "iris session iris -U %SYS < /home/irisowner/misc/enableshard.cos"
docker-compose exec data-2 bash -c "iris session iris -U %SYS < /home/irisowner/misc/enableshard.cos"

docker-compose exec data-0 iris restart iris quietly > /dev/null
docker-compose exec data-1 iris restart iris quietly > /dev/null
docker-compose exec data-2 iris restart iris quietly > /dev/null
#docker-compose restart data-0
#docker-compose restart data-1
#docker-compose restart data-2

docker-compose exec -T data-0 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T data-1 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T data-2 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"

docker-compose exec data-0 bash -c "iris session iris -U %SYS < /home/irisowner/misc/assign-shards.cos"

docker-compose exec data-0 bash -c "iris session iris -U USER < /home/irisowner/misc/import.cos"
