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
    @mc_driver = MCDriver.new
  end

  def run
    @bot.command :hello do |event|
      event.send_message("hallo,world.#{event.user.name}")
    end

    @bot.message do |event|
      bot_obj = event.bot
      message_obj = event.message
      # p bot_obj.users # チャット参加者
      # p message_obj.content # 発言内容
      # p message_obj.author # 発言者
      # p message_obj.timestamp # 発言時間

      # 発言内容をminecraft serverに送信する
      result = @mc_driver.send(message_obj.content)

      # 送信が成功しなかった場合、discordのチャットに送信失敗を出力する
      event.respond("送信失敗：#{message_obj.content}") unless result
    end

    @bot.run
  end
end
