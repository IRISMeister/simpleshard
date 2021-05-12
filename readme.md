## 目的
shardingは複数のノードを扱うため、ちょっとした動作確認を行うにも、環境作成やコマンド実行、ログの確認などが結構大変です。これらを簡便に行える環境をDockerにて作成しました。  
注)2020.4以後で動作確認しています。コミュニティエディションでは動作しません。  

## 起動

Shardが有効なx64コンテナ用のライセンスキーを./license/iris.keyに配置してください。
```
$ ./start-pri2021.sh
```
DATAノード*3台のノードレベルシャードが構成されます。  
data-0コンテナがMASTERとして動作します。  
data-0コンテナのIRISDMデータベースに通常のテーブルのデータが保持されます。  
data-0,data-1,data-2コンテナのIRISSHARDデータベースにshardテーブルのデータが保持されます。  

クライアント(アプリケーション)は、接続先としてdata-0のIRISDMネームスペースを使用します。  
(コンテナの1972ポートはホストO/Sの1972に公開されています)  
jdbc接続先の例 - jdbc:IRIS://irishost:1972/irisdm

## データロード
下記のテーブルの作成およびデータロードが可能です。
1. salesテーブル  

|テーブル名|シャード|Shard Key|
|:--|:--|:--|
|sales|Yes|(Auto)|

- SimpleLoaderによるロード  
[loader/shell/sales.sh](loader/shell/sales.sh)が[SimpleMover](https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=ABULKLOAD)を使用して、[loader/sales.csv](loader/sales.csv)を高速ロードします。  
注) [start-pri2021.sh](start-pri2021.sh)から実行されています。

- ObjectScriptによるロード  
[load.mac](src/load.mac)を使用してロードを行います。
ただし、ObjectScriptからのデータロードは非常に低速です。  
https://docs.intersystems.com/iris20201/csp/docbookj/Doc.View.cls?KEY=GSCALE_sharding#GSCALE_sharding_tables_load  
実行するには、下記コマンドでロードを開始してください。
```
$ docker-compose exec data-0 iris session iris -U IRISDM load
```

- Javaによるロード  
[App.java](loader/build/src/main/java/com/example/App.java)によるランダムデータのロード例です。通常のJDBCプログラムです。
```
$ docker-compose exec loader sh
/app # cd loader/build/src/main/java/
/app/loader/build/src/main/java # ./build_and_run.sh
```


2. 複数のトランザクションテーブル

|テーブル名|シャード|Shard Key|
|:--|:--|:--|
|tx_table_main|Yes|JANCD|
|tx_table_sub1|Yes|JANCD|
|tx_table_sub2|Yes|(Auto)|
|master_table|No|N/A|

- SimpleLoaderによるロード  
実行するには、下記コマンドでロードを開始してください。
export.macによりCSVファイルを作成し、SimpleLoaderでロードを実行します。  
tx_table_sub1とtx_table_sub2には、全く同じ内容のデータがロードされます。  
```
$ ./load.sh
```
3. OpenData(NYCのタクシーのデータ)

|テーブル名|シャード|Shard Key|
|:--|:--|:--|
|green_tripdata|Yes|(Auto)|

- SimpleLoaderによるロード  
まず、データをダウンロードします。
```
$ curl https://s3.amazonaws.com/nyc-tlc/trip+data/green_tripdata_2016-01.csv | sed  '/^.$/d' > loader/green_tripdata_2016-01.csv
```
実行するには、下記コマンドでロードを開始してください。
```
$ docker-compose exec loader /app/loader/shell/green.sh
```

## アクセス
管理ポータルは下記のURLでアクセス可能です。ただし、irisihostはコンテナを起動したホスト名(もしくはIPアドレス)です。  
ユーザ・パスワードはSuperUser/SYS

|コンテナ名|URL|役割|
|:--|:--|:--|
|data-0|http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen|DATA,MASTER|
|data-1|http://irishost:9093/csp/sys/%25CSP.Portal.Home.zen|DATA|
|data-2|http://irishost:9094/csp/sys/%25CSP.Portal.Home.zen|DATA|

IRISセッションは下記でアクセス可能。O/S認証されるのでユーザ・パスワードは入力不要です。
```
$ docker-compose exec data-0 iris session iris -U IRISDM
$ docker-compose exec data-1 iris session iris -U IRISDM
$ docker-compose exec data-2 iris session iris -U IRISDM
```

IRIS内からSQLを実行するには、下記のコマンドを使用してください。(管理ポータルを使用しての実行も可能です)
```
$ docker-compose exec data-0 iris session iris -U IRISDM "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISDM>>set selectmode=odbc
[SQL]IRISDM>>select * from sales
[SQL]IRISDM>>q  [終了]
```

## データの分散
例えば、tx_table_mainテーブルは、1000000件のレコードを保持しています。
```
$ docker-compose exec data-0 iris session iris -U IRISDM "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISDM>>select count(*) from tx_table_main
1.      select count(*) from tx_table_main
Aggregate_1
1000000
```
このテーブルのデータの実体は、各データノードのIRISCLUSTERネームスペース経由で確認することが出来ます。  
(テーブル名はIRIS_Shard_User.tx_table_mainテーブルになります)
各件数を合計すると、335812 + 331508 + 332680 = 1000000となり、tx_table_mainの件数に一致します、

```
$ docker-compose exec data-0 iris session iris -U IRISCLUSTER "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISCLUSTER>>select count(*) from IRIS_Shard_User.tx_table_main
Aggregate_1
335812
[SQL]IRISCLUSTER>>q  [終了]

$ docker-compose exec data-1 iris session iris -U IRISCLUSTER "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISCLUSTER>>select count(*) from IRIS_Shard_User.tx_table_main
Aggregate_1
331508

$ docker-compose exec data-2 iris session iris -U IRISCLUSTER "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISCLUSTER>>select count(*) from IRIS_Shard_User.tx_table_main
Aggregate_1
332680
```
tx_table_mainはshardキーにjancdを指定していますので、jancdのグルーピングが各データノードで完結していることを確認できます。

```
$ docker-compose exec data-0 iris session iris -U IRISDM "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISDM>>select count(*),jancd from tx_table_main group by jancd having jancd='ABCDEFG3220'
Aggregate_1     JANCD
107     ABCDEFG3220
```

この例では、JANCD:ABCDEFG3220はdata-0データノードに配置されたことがわかります。
```
$ docker-compose exec data-0 iris session iris -U IRISCLUSTER "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISCLUSTER>>select count(*),jancd from IRIS_Shard_User.tx_table_main group by jancd having jancd='ABCDEFG3220'
Aggregate_1     JANCD
107     ABCDEFG3220

$ docker-compose exec data-1 iris session iris -U IRISCLUSTER "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISCLUSTER>>select count(*),jancd from IRIS_Shard_User.tx_table_main group by jancd having jancd='ABCDEFG3220'
Aggregate_1     JANCD
0 Rows(s) Affected

$ docker-compose exec data-2 iris session iris -U IRISCLUSTER "##class(%SYSTEM.SQL).Shell()"
[SQL]IRISCLUSTER>>select count(*),jancd from IRIS_Shard_User.tx_table_main group by jancd having jancd='ABCDEFG3220'
Aggregate_1     JANCD
0 Rows(s) Affected
```

## co-shardの影響測定
下記の1つ目のクエリはco-shardが有効に働くため、DATAノード間のトラフィックが抑制されます(その結果、良いレスポンスを期待できる)。トラフィックの計測は容易ではありませんが、mgstatを使用した下記の方法があります。RemGrefsはECP越えのデータアクセスの回数です。1つ目のクエリ実行時はあまり(全く)増えないはずです。一方、2つ目のクエリ実行時は、RemGrefsが大きく上昇する(つまりシャッフルのための通信が発生している)ことがわかります。[こちら](https://www.intersystems.com/jp/wp-content/uploads/sites/6/2018/06/summit1806.pdf)のP.30に簡単な解説があります。  
注) data-0はマスタとして機能しておりRemGrefsは常に発生しますので、計測対象はdata-1あるいはdata-2を使用します。

```
1つ目のクエリ
$ docker-compose exec data-0 iris session iris -U IRISDM "##class(%SYSTEM.SQL).Shell()
[SQL]IRISDM>> select SUM(Price1),m.StoreCode from tx_table_main m inner join tx_table_sub1 s on m.jancd=s.jancd group by m.StoreCode
2つ目のクエリ
[SQL]IRISDM>> select SUM(Price1),m.StoreCode from tx_table_main m inner join tx_table_sub2 s on m.jancd=s.jancd group by m.StoreCode
```

mgstatは多くの情報を表示するので、以下では今回の興味の対象となる一部のカラムだけ選別しています。(mgstatの引数は、「1秒ごとに15秒間取得する」の意味です)
```
$ docker-compose exec -T data-1 iris session iris -U %SYS "mgstat(1,15,0)" | awk -W interactive -F, '{print $3 $4 $25 $26}'

1つ目のクエリ実行時の出力...
  Glorefs RemGrefs  BytSnt  BytRcd
      213        0       0       0
   203273       15     104      24
   349886        0       0       0
   369862        0       0       0
   353751        0       0       0
   351734        0       0       0
   371462        0       0       0
   377092        0       0       0
   278351      107    3404     192
      224        0       0       0
      191        0       0       0

2つ目のクエリ実行時の出力...
  Glorefs RemGrefs  BytSnt  BytRcd
      191        0       0       0
    23265   151887     160    5632
   108501   730012       0       0
    94960   637866       0       0
   107242   722859       0       0
   869407     1171    2124     112
   788359        0    1080      24
   756165        0       0       0
   248335   595201    2148     112
    86237   578320    1080      24
   102503   688197       0       0
    56172   377031    3428     152
      191        0       0       0

```
## 停止
```
$ ./stop.sh
```
