#!/bin/bash
docker-compose up -d data-0
docker-compose exec -T data-0 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 120"
docker-compose up -d
docker-compose exec -T data-1 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 120"
docker-compose exec -T data-2 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 120"

chmod 777 export
chmod 777 misc
docker-compose exec -T data-0 iris session iris -U IRISDM < misc/import.cos

docker-compose exec loader /app/loader/shell/sales.sh

# mind PL164702 ...