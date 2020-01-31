class DiscordBot
  TOKEN = Config::DISCORD_BOT[:token]
  CLIENT_ID = Config::DISCORD_BOT[:client_id]
  CONFIG = {
    token: TOKEN,
    client_id: CLIENT_ID,
    prefix:'/'
  }
  def initialize
    @bot = Discordrb::Commands::CommandBot.new (CONFIG)
  end

  def run
    @bot.command :hello do |event|
      event.send_message("hallo,world.#{event.user.name}")
    end

    @bot.message do |event|
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

    @bot.run
  end
end
