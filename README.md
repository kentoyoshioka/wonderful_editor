# Wonderful_editor
## 概要

Ruby on Rails の勉強の成果としてのスクールでの課題を作成しました。
Qiita 風の記事作成アプリになります。
アプリケーションは Heroku にてデプロイしております。

※ フロントエンド側に関してはスクールにて用意された物を使用しておりますが、フロントエンドサイドも現在学習中でいずれアップデートしていこうと考えております。

## 動作環境

- Ruby: 2.7.2
- Rails: 6.0.3.2
- Vue.js: 2.6.11
- DB: PostgreSQL(Docker で導入)

## 実装機能
### 記事関連
- 記事一覧機能(トップページ)
- 記事CRUD (一覧以外)
- 記事の下書き機能

### ユーザー関連
- ユーザー登録・サインイン/サインアウト
- マイページ（自分が書いた記事の一覧）

## 採用 gem 一覧
- active_model_serializers
- devise_token_auth
- rubocop-rails rubocop-rspec
- annotate
- pry-byebug, pry-rails, pry-doc
