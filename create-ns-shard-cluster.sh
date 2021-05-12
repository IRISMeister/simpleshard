#!/bin/bash -e
docker-compose exec -T data-0 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T data-1 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T data-2 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"

docker-compose exec -T data-0 iris session iris -U %SYS < misc/assign-shards.cos

chmod 777 export
chmod 777 misc
docker-compose exec -T data-0 iris session iris -U USER < misc/import.cos
