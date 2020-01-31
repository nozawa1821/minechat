# encoding: utf-8

# 既存ライブラリの読み込み
require 'fileutils'
require 'yaml'
require 'socket'
require 'thread'
require 'discordrb'
require 'miyabi'

# コンフィグファイルの読み込み
require './config/config'

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
