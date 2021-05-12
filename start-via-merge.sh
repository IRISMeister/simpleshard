#!/bin/bash
echo "This is experimental. May not work."

docker-compose up -d data-0
docker-compose exec -T data-0 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh 'iris' 60"

# Need a robust way to know if data-0 shard master is ready to accept attach requests.
# this?
# 05/12/21-16:41:21:835 (794) 0 [Utility.Event] Enabling logons
# 05/12/21-16:41:21:839 (794) 0 [Utility.Event] Initializing Interoperability during system startup
# 05/12/21-16:41:21:840 (794) 0 [Utility.Event] ShardRole changed to node1
# 05/12/21-16:41:21:840 (794) 0 [Utility.Event] Initializing data node
#     ・
# 05/12/21-16:41:26:740 (986) 0 [Utility.Event] Rebuild of Extent index completed
# 05/12/21-16:42:27:071 (1052) 0 [Utility.Event] WorkQueue: Starting work queue daemon parent=794  <= what tooks so long?
#     ・
# 05/12/21-16:42:27:153 (794) 0 [Utility.Event] Initialize data node completed

sleep 60
docker-compose up -d
docker-compose exec -T data-1 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh 'iris' 60"
docker-compose exec -T data-2 bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh 'iris' 60"

chmod 777 export
chmod 777 misc
docker-compose exec -T data-0 iris session iris -U IRISDM < misc/import.cos

docker-compose exec loader /app/loader/shell/sales.sh

# mind PL164702 ...