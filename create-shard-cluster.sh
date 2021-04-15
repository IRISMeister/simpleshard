#!/bin/bash -e
docker-compose exec -T data01 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
docker-compose exec -T data02 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
docker-compose exec -T data03 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"

docker-compose exec data01 bash -c "iris session iris -U %SYS < /home/irisowner/misc/enableshard.cos"
docker-compose exec data02 bash -c "iris session iris -U %SYS < /home/irisowner/misc/enableshard.cos"
docker-compose exec data03 bash -c "iris session iris -U %SYS < /home/irisowner/misc/enableshard.cos"

docker-compose exec data01 iris restart iris quietly > /dev/null
docker-compose exec data02 iris restart iris quietly > /dev/null
docker-compose exec data03 iris restart iris quietly > /dev/null
#docker-compose restart data01
#docker-compose restart data02
#docker-compose restart data03

docker-compose exec -T data01 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
docker-compose exec -T data02 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
docker-compose exec -T data03 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"

docker-compose exec data01 bash -c "iris session iris -U %SYS < /home/irisowner/misc/initialize.cos"
docker-compose exec data02 bash -c "iris session iris -U %SYS < /home/irisowner/misc/join.cos"
docker-compose exec data03 bash -c "iris session iris -U %SYS < /home/irisowner/misc/join.cos"
docker-compose exec data01 bash -c "iris session iris -U %SYS < /home/irisowner/misc/verify.cos"

docker-compose exec data01 bash -c "iris session iris -U IRISDM < /home/irisowner/misc/import.cos"
