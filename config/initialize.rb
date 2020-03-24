# encoding: utf-8

# 既存ライブラリの読み込み
require 'active_support/all'
require 'fileutils'
require 'yaml'
require 'socket'
require 'thread'
require 'discordrb'
require 'miyabi'
require 'i18n'
require 'sqlite3'
require 'sequel'

# 多言語化ライブラリの読み込み
I18n.load_path = Dir.glob('./locale/*.yml').map{|path| [path]}

# コンフィグファイルの読み込み
require './config/config'

# TODO: databaseが作成されていない場合、作成する
db_sqlite = Config::MINECHAT_DB
# 初回実行時DB作成処理
unless File.exist?(db_sqlite)
  puts "\e[33mデータベースを初期化します\e[0m"

  db = Sequel.sqlite(db_sqlite, results_as_hash: true)

  # テーブル追加
  unless db.table_exists? :discord_users
    db.create_table :discord_users do
      primary_key :id
      String :discord_id
      String :user_name
      Integer :permission_level
      String :created_at
      String :updated_at
    end
  end

  unless db.table_exists? :commands
    db.create_table :commands do
      primary_key :id
      String :command_name
      Integer :permission_level
      String :created_at
      String :updated_at
    end

    db[:commands].insert(command_name: 'say', permission_level: 0)
    db[:commands].insert(command_name: 'msg', permission_level: 0)
  end
  puts "\e[32mデータベースの初期化が完了しました！\e[0m"
end

# 自作ライブラリに関する設定
# Dir['./config/initializers/*.rb'].sort.each { |f| require f }

begin
  # 自作ライブラリの読み込み
  Dir['./lib/**/*.rb'].sort.each { |f| require f }
rescue => e
  if Object.const_defined?(:PROGRAM_LOGGER)
    puts "ライブラリの読み込み時にエラーが発生しました::#{e}"
  end

  raise e
end
