# Sysdigによるランタイムモニタリングの導入

このモジュールでは以下のことを行います。

- SysdigオーケストレーターをTerraformで実装します
- Sysdig Workload エージェントをコンテナ イメージに含めます
- 実際にコンテナに対して攻撃をしてみます
- 攻撃内容をSysdig管理コンソールから確認します



## CI/CD処理の概要

CI/CD処理には以下のワークフローファイルを使用します。

- CI: contents/module4/container-ci.yaml
- CD: contents/module4/app-cd.yaml

- `contents/module4/container-ci.yaml` では以下のような処理を行っています。
    1. ECRへのログイン
    2. Sysdig CLIスキャナーのダウンロード
    3. コンテナイメージのビルドとSysdig CLIスキャナーを使ったコンテナイメージスキャン
    4. コンテナイメージをECRにpush
    5. ecspressoをインストールしてECSデプロイするための構成が正しいことを検証
    6. ECRにpushしたコンテナイメージを削除
- `contents/module4/app-cd.yaml` では以下のような処理を行っています。
    1. ECRへのログイン
    2. コンテナイメージのビルドとECRにpush
    3. ecspressoをインストールしてECSデプロイするための構成が正しいことを検証
    4. ecspressoによるECSタスク定義及びECSサービスのデプロイ


## GitHub ActionsワークフローにアプリケーションのCI/CDを追加する

> [!TIP]
> 実際にプルリクエストをトリガーとしたワークフローを使う場合は、GitHubのブランチ保護ルールを併用することを推奨します。これによってワークフローが成功していないとマージが不可といったことを実現できます

### Sysdig Secure APIトークンの確認

1. Sysdig管理画面にログインします。ご用意頂いたメールアドレス宛にSysdig管理画面への招待メールをお送りしていますので、そちらからログインをお願いします
    1. Googleアカウントの場合、シングルサインオンで簡単にログインできます
2. Sysdig管理画面に入ったら以下のような画面が出るので画面下部の *Get Into Sysdig* ボタンをクリックします
    1. <img src="../images/module4/sysdig1.jpg" width=100%>
3. Home画面で以下のように画面下部の自ユーザ名をクリックし、 *Sysdig API Tokens* をクリックします
    1. <img src="../images/module4/sysdig2.jpg" width=100%>
4. Sysdig Secure API Tokenの欄の横にあるコピーボタンをクリックして、コピーした値をメモ帳などに控えておきます
    1. <img src="../images/module4/sysdig3.jpg" width=100%>

### コンテナCI処理の実行

1. GitHubリポジトリ側でワークフロー内で使用するsecretsの設定をしておきます
    1. ご自身のGitHubリポジトリ画面を開きます。以下のようなURLのはずです
        1. https://github.com/＜自身のGitHubID＞/Handson_with_Secure_container_operations
    2. Settingsを選択します
        1. <img src="../images/module3/github1.jpg" width=100%>
    3. Secrets and variablesの「Actions」を選択します
        1. <img src="../images/module3/github2.jpg" width=100%>
    4. *New repository secret* ボタンをクリックします
    5. Secretsに以下を登録します
        - Name: SYSDIG_SECURE_API_TOKEN
        - Secret: Sysdig管理画面で確認したSysdig Secure APIトークンの値
2. GitHub ActionsのワークフローとしてGitHubに認識させるためにはリポジトリ内の所定のディレクトリに置く必要があります
    1. `container-ci.yaml`と`app-cd.yaml`を `.github/workflows` ディレクトリに格納しましょう
        1. ```
            # developブランチであることを確認
            git branch
            # ワークフローファイルの格納
            cd Handson_with_Secure_container_operations/contents/module4/
            git mv container-ci.yaml ../../.github/workflows/
            git mv app-cd.yaml ../../.github/workflows/
3. またこのワークフローでは `app` ディレクトリ配下のファイルの変更を検知してワークフローが起動するような設定になっています。そのため `terraform` ディレクトリ配下のファイルを編集します
    1. `app/javascript-sample-app/index.js`を開き、21行目のコメントアウトされている箇所に適当な文字を記載してください
        1. ```
            // config 適当な文字列
4. 編集が完了したら、ファイルをGitHubリポジトリにpushします
    1. ```
        # コミットとpush
        git add --all
        git commit -m "add app workflow"
        git push myrepo develop
5. ワークフローファイルの追加ができたので実際に動かしてみます。ブラウザ上でdevelopブランチからmainブランチへのプルリクエストを出します
    1. <img src="../images/module3/github4.jpg" width=100%>
6. *New pull request* ボタンをクリックします
7. developブランチからmainブランチへのプルリクエストであることを以下のように指定します
    1. <img src="../images/module3/github5.jpg" width=100%>
8. *Create pull request* ボタンをクリックします
9. mainブランチへのプルリクエストをトリガーにワークフロー処理が動き始めたはずです。
    - またリポジトリ画面上部の *Actions* タブからも実行の様子が確認できます
        - <img src="../images/module3/github6.jpg" width=100%>


### コンテナイメージ脆弱性の確認

1. ワークフロー処理は失敗したはずです。失敗した原因はコンテナイメージに脆弱性が含まれているからです
2. どのような脆弱性があるのかをSysdig管理画面から確認してみます
3. Sysdig管理画面に戻り、*Vulnerabilities/Pipeline* を選択します
    1. <img src="../images/module4/sysdig4.jpg" width=100%>
4. マウスオーバーするとコンテナイメージのタグが確認できるので、先程のCI処理の中でビルドしたコンテナイメージをクリックします（タグはdevelopブランチの最新のコミットIDになっています）
    1. <img src="../images/module4/sysdig5.jpg" width=100%>
5. 多くの脆弱性がコンテナイメージに含まれていることを確認できます

### コンテナイメージ脆弱性の修正

1. コンテナイメージの脆弱性をDockerコンテナのベースイメージを変更することで修正します
2. 以下のファイルをコピーし、再度リポジトリにpushします
    1. `Dockerfile`を `.github/workflows` ディレクトリに格納しましょう
        1. ```
            # Dockerfileの格納
            cd Handson_with_Secure_container_operations/contents/module4/
            git mv Dockerfile ../../app/javascript-sample-app
            git add --all
            git commit -m "update dockerfile"
            git push myrepo develop
3. 既にdevelopブランチでプルリクエスト作成済であるところにpushをしたのでプルリクエストが更新されます。更新をトリガーにワークフローが起動します
4. ワークフローが完了したら、再度 *コンテナイメージ脆弱性の確認* と同様の手順で脆弱性の数がどの程度変わったか確認してみましょう

### AWS環境へのデプロイ

1. プルリクエストをトリガーとした、CIのワークフロー処理が正常に完了したら、次はmainブランチにpushをすることで実際にAWS環境へのデプロイを行います
    1.  プルリクエストの画面に戻り、 *Merge pull request* ボタンをクリックします
        1.  <img src="../images/module3/github7.jpg" width=100%>
2.  mainブランチへのマージをトリガーに再度、ワークフローが起動します
    1.  またリポジトリ画面上部の *Actions* タブからも実行の様子を確認してみましょう
3.  ALBの画面からALBのDNS名を確認し、確認したDNS名をブラウザに入力しアクセスしてみましょう

[Next: Sysdigによるランタイムモニタリングの導入](../module5/module5.md)
