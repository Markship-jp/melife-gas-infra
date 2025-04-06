# melife-gas-infra

## 概要

このリポジトリは、melife-gasのインフラストラクチャをTerraformで管理するためのコードである。

## ディレクトリ構造

```
terraform/
├── dev/                # 開発環境
│   ├── cicd/          # CI/CD関連リソース
│   │   ├── file/      # CI/CD設定ファイル
│   │   └── *.tf       # CI/CD用Terraformファイル
│   └── infra/         # インフラリソース
│       ├── file/      # インフラ設定ファイル
│       └── *.tf       # インフラ用Terraformファイル
├── stg/                # ステージング環境
│   ├── cicd/
│   └── infra/
└── prd/                # 本番環境
    ├── cicd/
    └── infra/
```

## 環境別の管理

本プロジェクトでは、以下の3つの環境を管理している：

- **開発環境 (dev)**: 開発用環境
- **ステージング環境 (stg)**: 評価用環境
- **本番環境 (prd)**: 本番用環境

各環境は独立したAWSアカウントで分離されており、それぞれのTerraformの状態ファイル（tfstate）も各環境のAWSアカウント上で管理されている。  
各環境のディレクトリに移動して terraform init を実行することで、その環境のリソース管理を開始できる。

## 状態ファイル（tfstate）の管理

各環境のTerraform状態ファイルは、対応するAWSアカウント上のS3バケットで管理されている：

- 開発環境: dev-melife-gas-tfstate バケット（開発用AWSアカウント内）
- ステージング環境: stg-melife-gas-tfstate バケット（ステージング用AWSアカウント内）
- 本番環境: prd-melife-gas-tfstate バケット（本番用AWSアカウント内）

各環境内でも、インフラリソースとCI/CDリソースは別々の状態ファイルで管理されている：

- インフラリソース: terraform.tfstate
- CI/CDリソース: cicd/terraform.tfstate

## CloudFormationテンプレートを利用したリソース管理

Terraformのネイティブリソースではなく、CloudFormationテンプレートをTerraformからラップして管理しているリソースは以下の通りである：

- **GuardDuty**: Amazon GuardDutyの一部機能はTerraformで直接サポートされていないため、CloudFormationテンプレートを使用して設定

## コンソールから構築したもの

Terraformで管理していない、AWSコンソールから手動で構築・設定したリソースは以下の通りである：

- **SESの本番利用申請**: メール送信機能を本番環境で利用するためのSES利用制限解除申請
- **SESのSMTPユーザーの作成**: メール送信のためのSMTPユーザーはコンソールから手動で作成
- **IAMユーザーの作成**: 開発者用およびCI/CD用のIAMユーザー
- **GithubとCodepipelineの接続**: CodeStarConnectionsの接続承認プロセス
- **パラメータストアの値設定**: SystemsManagerパラメータストアの枠はTerraformで作成しているが、実際の値はコンソールから手動で設定する必要がある

## AWS認証情報の管理

Terraformを実行するディレクトリ（例：terraform/dev/infra/）に .envrc ファイルを作成し、direnvを使用してAWS認証情報を管理することを推奨する：

```bash
# AWS認証情報
export AWS_PROFILE=melife-gas-dev  # 開発環境用プロファイル
# export AWS_PROFILE=melife-gas-stg  # ステージング環境用プロファイル
# export AWS_PROFILE=melife-gas-prd  # 本番環境用プロファイル
```

環境ごとに適切なAWSプロファイルを設定し、作業する環境に合わせてコメントアウトを調整する。

## 注意事項

- 本番環境の変更は慎重に行い、必ず事前に terraform plan を確認すること