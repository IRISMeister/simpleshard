目的
shardingの動作確認を行うための環境作成

```
$ docker-compose up -d
$ ./create-shard-cluster.sh
```

DATAノード*3台のノードレベルシャードが構成されます。
ネームスペース IRISDMにshardテーブルsalesが作成されます。

データロードを行います。
サンプルsrc/load.mac  (ただし、ObjectScriptからのデータロードは非常に低速です)

ポータルは下記のURLでアクセス可能。 SuperUser/SYS
```
http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen
http://irishost:9093/csp/sys/%25CSP.Portal.Home.zen
http://irishost:9094/csp/sys/%25CSP.Portal.Home.zen
```

セッションは下記でアクセス可能。O/S認証されるのでユーザ・パスワードは入力不要。
```
$ docker-compose exec data01 iris session iris -U IRISDM
$ docker-compose exec data02 iris session iris -U IRISDM
$ docker-compose exec data03 iris session iris -U IRISDM
```
