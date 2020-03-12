# MINECHAT
Minecraftとdiscordのチャット欄を連携するツールを作成したよ  

## Installation
### 環境構築

minechatを稼働させるためにRubyとgitをインストールしていきます  
※環境構築済みの方は飛ばしてください（rubyとbundlerのバージョンだけ気をつけてください）

実行環境はLinuxのCentOS 6です  
環境によってコマンドが異なりますのであらかじめ確認してから環境構築を進めてください  

また、Minecraft serverと同様のserverにプログラムを稼働させる想定で話を進めています  

・centOSのバージョンを確認します
```
$ cat /etc/redhat-release
CentOS release 6.10 (Final)
```

#### gitのインストール
```
$ sudo yum install git
```

#### rubyのインストール
##### rbenvのインストール
`rbenv`はrubyのバージョンを管理するツールです

・リポジトリのダウンロード
```
$ git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```

・`rbenv`にパスを通してbashを再読み込みします
```
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
$ ~/.rbenv/bin/rbenv init
$ source ~/.bash_profile
```

・`rbenv`が読み込まれているかを確認
```
$ rbenv -v
rbenv 1.1.1-2-g615f844
```

バージョンが上記のように正しく表示されたら次へ行きましょう

##### ruby-buildのインストール
`ruby-build`はrbenvのプラグインにあたるツールです
rubyをインストールするための`rbenv install`コマンドを実行するために必要です

・リポジトリのダウンロード
```
$ git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

・`ruby-build`のインストール
```
$ sudo ~/.rbenv/plugins/ruby-build/install.sh
```

以下のコマンドを実行できればインストール成功です
```
$ rbenv install -l
```

##### Ruby のインストール
・`Ruby`をインストールするのに必要なパッケージをインストールします
```
$ sudo yum install -y openssl-devel readline-devel zlib-devel
```
・`Ruby`をインストールします
```
$ rbenv install 2.5.1
```
・`Ruby`へパスを通します
```
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
$ source ~/.bash_profile
```
・`Ruby`のバージョンを固定します
```
$ rbenv global 2.5.1
```
・`Ruby`の正しいバージョンが読み込まれているかを確認します
```
$ ruby -v
ruby 2.5.1p57
```

##### rubygemsのインストール
・インストール
```
$ yum install rubygems
```
・`rubygems`が読み込まれているかを確認
```
$ gem -v
```

##### bundlerのインストール
・インストール  
※`minechat`では`Gemfile.lock`で`bundler`のバージョンが固定されているので下記のバージョンに合わせてください
```
$ gem install bundler -v '1.16.2'
```
・`bundler`が読み込まれているかを確認
```
$ bundle -v
Bundler version 1.16.2
```

  
これで環境構築は完了です。お疲れ様でした。
  

### minechatのインストール
・任意のディレクトリにminechatをダウンロード  
※自分は`Minecraft server`と同じ階層に配置しています。(`/opt/`配下)

```
$ cd <minechatを配置するディレクトリ>
$ git clone https://github.com/nozawa1821/minechat.git
```

・`minechat`リポジトリに移動
```
$ cd ./minechat
```

・`minechat`を動かすために必要なライブラリをインストール
```
bundle install
```

## Settings
`Minecraft server`と`discord`を連携させるために設定をしていきます。
### Minecraft serverの設定
Minecraft serverと外部ツールとの連携を可能にする`rcon`と呼ばれる仕組みを利用するため
`server.properties`の設定を変更します

・Minecraft serverディレクトリに移動して`server.properties`というファイルをviで開きます
```
$ cd <Minecraft server>
$ vi server.properties
```

viで開いたら下記の設定項目を`=`右側の値に書き換えてください
```
rcon.port=<任意のポート番号を入力(デフォルトは25575)>
rcon.password=<任意のパスワードを入力(無記入でもok)>
enable-rcon=true
```

・設定が完了したら以下の値を控えておいてください。
  * rcon.port
  * rcon.password
  * Minecraft serverの出力ログ格納ディレクトリの絶対パス  

  logsディレクトリに格納された`latest.log`までの絶対パスをメモしておいてください  

※以下は絶対パスを取得するコマンド
```
readlink -f <Minecraft server>/logs/latest.log
```

### discord botの設定
・discord botを用意してください  
　　discord bot の作成は下記を参照して作成してください  
> [Discord Botアカウント初期設定ガイド for Developer - Qiita](https://qiita.com/1ntegrale9/items/cb285053f2fa5d0cccdf)

・discord botを用意したら以下のトークン、IDを控えておいてください。
  * アクセストークン  
  上記の記事中に出てきますので参照してください
  * CLIENT ID  
  botのクライアントID  
  Discord DEVELOPER PORTALの Applications → settings → General Informationのページで取得できます
  * CHANNEL ID  
  Minecraft logを送信したいチャンネルのID  
  discordの 任意のDiscord server → 任意のテキストチャンネルを右クリック → IDをコピーで取得できます

### minechatの設定
・minehatに移動して`config.rb`というファイルをviで開きます
```
vi config/config.rb
```

・`config.rb`を開いたらMinecraft、discord botで控えた値を設定していきます  
#### discord botの設定を記入
#でコメントアウトされた「discord Botの設定」以下の値を変更します  
  * token: '<アクセストークンを入力>'
  * client_id: '<CLIENT IDを入力>'
  * channel_id: '<CHANNEL IDを入力>'

#### Minecraftの設定を記入
#でコメントアウトされた「Minecraft の設定」以下の値を変更します
  * rcon_port: '<rcon.portを入力>'
  * rcon_password: '<rcon.paswordを入力>'
  * monitored_log: '<出力ログ格納ディレクトリの絶対パスを入力>'

## Usage
### minechatをバックグラウンドで起動する
・minechatリポジトリに移動してフォアグラウンドで起動できるかを確認します
```
$ ruby minechat.rb
```

・minechatをバックグラウンドで起動します
```
$ nohup ruby main.rb &
```

・minechatが稼働しているかを確認する
以下の出力が出ればOK
```
ps aux | grep rub
root  xxxxx  x.x  x.x xxxxxx xxx xxx/x R+ xx:xx x:xx minechat.rb
```

## How to
あとで書く

## Author
[noziming](https://noziming.work)

## Licence
MIT
