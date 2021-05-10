#!/bin/bash -e

microk8s kubectl exec -i data-0 -- bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
microk8s kubectl exec -i data-1 -- bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
microk8s kubectl exec -i data-2 -- bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"

microk8s kubectl exec -i data-0 -- iris session iris -U %SYS < ../misc/enableshard.cos
microk8s kubectl exec -i data-1 -- iris session iris -U %SYS < ../misc/enableshard.cos
microk8s kubectl exec -i data-2 -- iris session iris -U %SYS < ../misc/enableshard.cos

microk8s kubectl exec -i data-0 -- iris restart iris quietly > /dev/null
microk8s kubectl exec -i data-1 -- iris restart iris quietly > /dev/null
microk8s kubectl exec -i data-2 -- iris restart iris quietly > /dev/null

microk8s kubectl exec -i data-0 -- bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
microk8s kubectl exec -i data-1 -- bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
microk8s kubectl exec -i data-2 -- bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"

microk8s kubectl exec -i data-0 -- iris session iris -U %SYS < ../misc/initialize.cos
microk8s kubectl exec -i data-1 -- iris session iris -U %SYS < ../misc/join.cos
microk8s kubectl exec -i data-2 -- iris session iris -U %SYS < ../misc/join.cos
microk8s kubectl exec -i data-0 -- iris session iris -U %SYS < ../misc/verify.cos

microk8s kubectl cp ../src data-0:/home/irisowner/src
microk8s kubectl cp ../misc data-0:/home/irisowner/misc
microk8s kubectl exec -i data-0 -- iris session iris -U IRISDM < ../misc/import.cos
