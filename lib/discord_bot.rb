class DiscordBot
  def initialize(bot)
    @discord_bot = bot
  end

  def run
    # discordbotのコマンドを追加
    @discord_bot.command :hello_world do |event|
      event.send_message("HELLO WORLD. #{event.user.name}")
    end

    # 取得した内容をトレースし、コマンドの実行もしくはminecraftに内容を送信する
    @discord_bot.message do |event|
      user_name = event.user.name # 発言者
      message = event.message.content # 発言内容
      # event.message.timestamp # 発言時間

      # 発言内容をminecraft serverに送信する
      mc_driver = MCDriver.new
      result = mc_driver.send(user_name, message)

      # 送信が成功しなかった場合、discordのチャットに送信失敗を出力する
      error_msg = "以下の内容はminecraftに送信していません。\n> #{message}\n"
      event.respond(error_msg) unless result
    end

    @discord_bot.run
  rescue => e
    puts "discordbot側でエラーが発生しました：#{e}"
  end
end
