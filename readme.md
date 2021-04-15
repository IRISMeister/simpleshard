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
[start.sh](start.sh)から実行されています。

- ObjectScriptによるロード  
[load.mac](src/load.mac)を使用してロードを行います。
ただし、ObjectScriptからのデータロードは非常に低速です。  
https://docs.intersystems.com/iris20201/csp/docbookj/Doc.View.cls?KEY=GSCALE_sharding#GSCALE_sharding_tables_load  
実行するには、起動後、下記コマンドでロードを開始してください。
```
$ docker-compose exec data01 iris session iris -U IRISDM load
```
- SimpleLoaderによる大量ロード  
export.macによりCSVファイルを作成し、SimpleLoaderでロードを実行します。下記のテーブルを作成します。  
tx_table_sub1とtx_table_sub2はShardキーだけが異なるテーブルで、全く同じ内容のデータがロードされます。  

|テーブル名|シャード|Shard Key|
|:--|:--|:--|
|tx_table_main|Yes|JANCD|
|tx_table_sub1|Yes|JANCD|
|tx_table_sub2|Yes|(Auto)|
|master_table|No|N/A|

```
$ ./load.sh
```
## アクセス
ポータルは下記のURLでアクセス可能。ただし、irisihostはコンテナを起動したホスト名(もしくはIPアドレス)です。  
ユーザ・パスワードはSuperUser/SYS

|コンテナ名|URL|役割|
|:--|:--|:--|
|data01|http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen|DATA,MASTER|
|data02|http://irishost:9093/csp/sys/%25CSP.Portal.Home.zen|DATA|
|data03|http://irishost:9094/csp/sys/%25CSP.Portal.Home.zen|DATA|

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
[SQL]IRISDM>>Q  [終了]
```

## co-shardの効果測定
下記の1つ目のクエリはco-shardが有効に働くため、DATAノード間のトラフィックが抑制されます(その結果、良いレスポンスを期待できる)。トラフィックの計測は容易ではありませんが、mgstatを使用した下記の方法があります。RemGrefsはECP越えのデータアクセスの回数です。1つ目のクエリ実行時はあまり(全く)増えないはずです。一方、2つ目のクエリ実行時は、RemGrefsが大きく上昇する(つまりシャッフルのための通信が発生している)ことがわかります。[こちら](https://www.intersystems.com/jp/wp-content/uploads/sites/6/2018/06/summit1806.pdf)のP.30に簡単な解説があります。  
注) data01はマスタとして機能しておりRemGrefsは常に発生しますので、計測対象はdata02あるいはdata03を使用します。

```
1つ目のクエリ
$ docker-compose exec data01 iris session iris -U IRISDM "##class(%SYSTEM.SQL).Shell()
[SQL]IRISDM>> select SUM(Price1),m.StoreCode from tx_table_main m inner join tx_table_sub1 s on m.jancd=s.jancd group by m.StoreCode
2つ目のクエリ
[SQL]IRISDM>> select SUM(Price1),m.StoreCode from tx_table_main m inner join tx_table_sub2 s on m.jancd=s.jancd group by m.StoreCode
```

```
$ docker-compose exec data02 iris session iris -U %SYS
%SYS>d ^mgstat(1,10000)
Date,       Time    ,  Glorefs, RemGrefs, GRratio,  PhyRds, Rdratio,

1つ目のクエリ実行時...
04/15/2021, 17:50:07,   308117,        0,       0,       0,       0,       
04/15/2021, 17:50:08,   203172,      103, 1972.54,       0,       0,       
04/15/2021, 17:50:09,      191,        0,       0,       0,       0,

2つ目のクエリ実行時...
04/15/2021, 17:50:18,    18072,   117367,     .15,       3,   38679,       
04/15/2021, 17:50:19,    90001,   603131,     .15,       0,       0,      
04/15/2021, 17:50:20,    88168,   590822,     .15,
```


## その他
OpenData(NYCのタクシーデータ)の取り込み
```
$ curl https://s3.amazonaws.com/nyc-tlc/trip+data/green_tripdata_2016-01.csv | sed  '/^.$/d' > loader/green_tripdata_2016-01.csv
$ docker-compose exec loader /app/loader/shell/green.sh
```

## 停止
```
$ ./stop.sh
```
