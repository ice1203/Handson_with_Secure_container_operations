ARG sysdig_agent_version=latest

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

# Sysdigのワークロードエージェントのインストール
FROM quay.io/sysdig/workload-agent:$sysdig_agent_version AS workload-agent

# 実行ステージ
FROM gcr.io/distroless/nodejs22-debian12

# ワークロードエージェントからエージェントをコピー
COPY --from=workload-agent /opt/draios /opt/draios
# ビルドステージからアプリケーションのディレクトリをコピー
COPY --chown=nonroot:nonroot --from=builder /usr/src/app /usr/src/app
USER nonroot

# 作業ディレクトリを設定
WORKDIR /usr/src/app

# アプリケーションを実行
ENTRYPOINT ["/opt/draios/bin/instrument", "/nodejs/bin/node"]
CMD ["index.js"]
