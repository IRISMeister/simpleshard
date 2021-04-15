#!/bin/sh
source /app/loader/shell/envs.sh
java -Dfile.encoding=UTF-8 -cp $ISCCLASSLIBS com.intersystems.datatransfer.SimpleMover p=/app/loader/tx_table_sub2.conf