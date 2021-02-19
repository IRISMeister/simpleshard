## 目的
shardingの動作確認を行うための環境作成

## 起動
Shardが有効なライセンスキーを./license/iris.keyに配置してください。

```
$ docker-compose up -d
$ ./create-shard-cluster.sh
```

DATAノード*3台のノードレベルシャードが構成されます。
ネームスペース IRISDMにshardテーブルsalesが作成されます。

## データロード
データロードを行います。
サンプルsrc/load.mac  (ただし、ObjectScriptからのデータロードは非常に低速です)

## アクセス
ポータルは下記のURLでアクセス可能。ただし、irisihostはコンテナを起動したホスト名(もしくはIPアドレス)です。  
ユーザ・パスワードはSuperUser/SYS
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
