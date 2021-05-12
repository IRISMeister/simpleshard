#!/bin/bash -e
docker-compose exec -T data-0 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T data-1 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T data-2 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"

docker-compose exec -T data-0 iris session iris -U %SYS < misc/initialize.cos
docker-compose exec -T data-1 iris session iris -U %SYS < misc/join.cos
docker-compose exec -T data-2 iris session iris -U %SYS < misc/join.cos
docker-compose exec -T data-0 iris session iris -U %SYS < misc/verify.cos

chmod 777 export
chmod 777 misc
docker-compose exec -T data-0 iris session iris -U IRISDM < misc/import.cos





