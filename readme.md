## 目的
shardingの動作確認を行うための環境作成。コミュニティエディションでは動作しません。  
CPF MergeおよびSimpleLoader使用のため、要2020.4～。

## 起動

Shardが有効なx64コンテナ用のライセンスキーを./license/iris.keyに配置してください。
```
$ ./start.sh
```
DATAノード*3台のノードレベルシャードが構成されます。  
data01コンテナがMASTERとして動作します。  
data01コンテナのIRISDMデータベースに通常のテーブルのデータが保持されます。  
data01,data02,data03コンテナのIRISSHARDデータベースにshardテーブルのデータが保持されます。  

クライアント(アプリケーション)は、接続先としてdata01のIRISDMネームスペースを使用します。  
(コンテナの1972ポートはホストO/Sの1972に公開されています)  
jdbc接続先の例 - jdbc:IRIS://irishost:1972/irisdm

## データロード
- SimpleLoaderによるロード
[loader/shell/sales.sh](loader/shell/sales.sh)が[SimpleMover](https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=ABULKLOAD)を使用して、[loader/sales.csv](loader/sales.csv)を高速ロードします。

- ObjectScriptによるロード
[load.mac](src/load.mac)を使用してロードを行います。
ただし、ObjectScriptからのデータロードは非常に低速です。  
https://docs.intersystems.com/iris20201/csp/docbookj/Doc.View.cls?KEY=GSCALE_sharding#GSCALE_sharding_tables_load
実行するには、起動後、下記コマンドでロードを開始してください。
```
$ docker-compose exec data01 iris session iris -U IRISDM load
```
- SimpleLoaderによる大量ロード
export.macによりCSVファイルを作成し、SimpleLoaderでロードを実行します。
```
$ docker-compose exec data01 iris session iris -U IRISDM export
$ ./load.sh
```
## アクセス
ポータルは下記のURLでアクセス可能。ただし、irisihostはコンテナを起動したホスト名(もしくはIPアドレス)です。  
ユーザ・パスワードはSuperUser/SYS

http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen
http://irishost:9093/csp/sys/%25CSP.Portal.Home.zen
http://irishost:9094/csp/sys/%25CSP.Portal.Home.zen

IRISセッションは下記でアクセス可能。O/S認証されるのでユーザ・パスワードは入力不要です。
```
$ docker-compose exec data01 iris session iris -U IRISDM
$ docker-compose exec data02 iris session iris -U IRISDM
$ docker-compose exec data03 iris session iris -U IRISDM
```

IRIS内からSQLを実行するには、下記のエントリを使用してください。
```
$ docker-compose exec data01 iris session iris -U IRISDM "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISDM>>set selectmode=odbc
[SQL]IRISDM>>select * from sales
[SQL]IRISDM>>select SUM(Price1),m.StoreCode from tx_table_main m inner join tx_table_sub1 s on m.jancd=s.jancd where m.orderdate between '2020-01-01'and '2020-01-31'  group by m.StoreCode
```

OpenData(NYCのタクシーデータ)の取り込み
```
$ curl https://s3.amazonaws.com/nyc-tlc/trip+data/green_tripdata_2016-01.csv | sed  '/^.$/d' > loader/green_tripdata_2016-01.csv
$ docker-compose exec loader /app/loader/shell/green.sh
```

## 停止
```
$ ./stop.sh
```
