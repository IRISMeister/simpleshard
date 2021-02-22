## 目的
shardingの動作確認を行うための環境作成。コミュニティエディションでは動作しません。
CPF MergeおよびSimpleLoader使用のため、要2020.4～。

## 起動
Shardが有効なx64コンテナ用のライセンスキーを./license/iris.keyに配置してください。

```
$ docker-compose up -d
$ ./create-shard-cluster.sh
```

DATAノード*3台のノードレベルシャードが構成されます。
ネームスペース IRISDMにshardテーブルsalesが作成されます。

## データロード
/create-shard-cluster.shが[SimpleMover](https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=ABULKLOAD)を使用して、loader/sales.csvを高速ロードします。

ObjectScriptからロード例  
src/load.mac  
ただし、ObjectScriptからのデータロードは非常に低速です。  
https://docs.intersystems.com/iris20201/csp/docbookj/Doc.View.cls?KEY=GSCALE_sharding#GSCALE_sharding_tables_load


## アクセス
ポータルは下記のURLでアクセス可能。ただし、irisihostはコンテナを起動したホスト名(もしくはIPアドレス)です。  
ユーザ・パスワードはSuperUser/SYS
```
http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen
http://irishost:9093/csp/sys/%25CSP.Portal.Home.zen
http://irishost:9094/csp/sys/%25CSP.Portal.Home.zen
```

IRISセッションは下記でアクセス可能。O/S認証されるのでユーザ・パスワードは入力不要です。
```
$ docker-compose exec data01 iris session iris -U IRISDM
$ docker-compose exec data02 iris session iris -U IRISDM
$ docker-compose exec data03 iris session iris -U IRISDM
```

OpenData(NYCのタクシーデータ)の取り込み
$ curl https://s3.amazonaws.com/nyc-tlc/trip+data/green_tripdata_2016-01.csv | sed  '/^.$/d' > loader/green_tripdata_2016-01.csv
$ docker-compose exec loader /app/loader/shell/green.sh
