# growing_sakeリポジトリ概要

Flutterで作成されています。  
このアプリはGooglePlayストアで「[日本酒を育てる](https://play.google.com/store/apps/details?id=com.highcom.growing_sake)」アプリとして公開されています。

## 日本酒を育てるアプリ概要

飲んだ日本酒を記録するだけではない「日本酒を育てる」ためのアプリです。  
飲み頃の日本酒は花が咲くと言ったりします。

日本酒の味を「五味」で評価したり、  
開栓後からの経過日数に応じた「香り」の強さをグラフで記録をつけたりして、  
さまざまな銘柄の日本酒の飲み頃を記録してみんなで日本酒を育てていきましょう！

### 機能紹介
- 自分で登録したデータはクラウドに保管されて一覧で表示
- 日本酒に特化したさまざまなデータ入力項目
- 開栓後からの「香り」の変化をグラフで記録できる
- タイムラインから他のユーザーが評価した日本酒の銘柄を参照
- さけのわAPIを利用して最新の銘柄名一覧から名前検索
- Google認証によりアカウントの作成をせずに利用可能

## 利用しているサービス

- Flutter
- さけのわデータのWebAPI
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Crashlytics

各サービスを実装するにあたり、参考にしたウェブサイト等を  
[Flutter+Firebaseアプリをリリースするまでに参考にしたウェブサイト集](https://qiita.com/highcom/items/0e2a97e25497651377ca)  
として記事にまとめています。
