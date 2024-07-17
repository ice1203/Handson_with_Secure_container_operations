# ビルドステージ
FROM node:22 AS builder

# アプリケーションのディレクトリを作成
WORKDIR /usr/src/app

# package.jsonとpackage-lock.jsonをコピー
COPY package*.json ./

# 依存関係をインストール
RUN npm install --production

# アプリケーションのソースコードをコピー
COPY . .

# 実行ステージ
FROM gcr.io/distroless/nodejs22-debian12

# ビルドステージからアプリケーションのディレクトリをコピー
COPY --from=builder /usr/src/app /usr/src/app

# 作業ディレクトリを設定
WORKDIR /usr/src/app

# アプリケーションを実行
CMD ["index.js"]
