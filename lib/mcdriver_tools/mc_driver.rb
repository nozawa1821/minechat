class MCDriver
  HOST = Config::MINECRAFT[:host]
  PORT = Config::MINECRAFT[:rcon_port]
  PASSWORD = Config::MINECRAFT[:rcon_password]
  PREFIX = Config::MINECRAFT[:command_prefix]
  attr_reader :user, :message, :error_message

  def initialize(discord_event)
    @authorized = false
    @transfer = CommandTransfer.new(HOST, PORT)
    @discord_event = discord_event
    @user_id = discord_event.user.id
  end

  # 内容をminecraftのチャットに送信する処理
  # return [boolean]
  def send(user, message)
    @user = user
    @message = message

    # 認証
    return false unless authorize

    # ユーザー名を変換する
    return false unless convert_user

    # 内容を変換する
    return false unless convert_message

    # minecraft serverにコマンドを送信する
    response = @transfer.send("#{PREFIX}#{@message}")

    # 返却値がnilならば、falseを返す
    return false if response.nil?

    # レスポンス内容をdiscordに表示する
    @discord_event.send_message "minecaftサーバーからのレスポンス：\n> #{response}" if response.present?

    return true
  rescue => e
    raise e
  end

  private
  # 内容をコマンド形式に変換する処理
  # return [boolean]
  def convert_message

    # 日本語文字をローマ字に変換する
    @message = convert_en_to_ja(@message)

    # 2バイト以上の文字を削除する
    @message = @message.chars.map{ |moji| moji if moji.bytesize == 1 }.join

    # コマンドを切り抜き
    match_data = @message.match(/^\/(\w+) (.*)$/)

    # 内容が送信できない場合、送信処理を実行しない
    return false unless message_check(match_data)

    # コマンド形式であれば値をそのまま返却する
    if !!match_data
      @message = "#{match_data[1]} #{match_data[2]}"
      return true
    end

    # 内容がコマンド形式で記述されていない場合はsayコマンドを付与変換する
    @message = "say <#{@user}> #{@message}"

    return true
  end

  # ユーザー名をローマ字に変換する処理
  # return [boolean]
  def convert_user
    # 日本語文字をローマ字に変換する
    @user = convert_en_to_ja(@user)

    # 2バイト以上の文字を削除する
    @user = @user.chars.map{ |moji| moji if moji.bytesize == 1 }.join

    return true
  end

  # サーバに送信できる内容か検閲する
  # return [boolean]
  def message_check(match_data)
    # 内容がコマンド形式になっていなければtrueを返す
    return true unless !!match_data

    # コマンドがリストに無い場合はfalseを返す
    command = COMMANDS.find(command_name: match_data[1])
    if command.blank?
      @error_message = "以下のコマンドは実行できません\n> /#{match_data[1]}"
      return false
    end

    # ユーザーの権限がコマンドの実行権限より高い場合はtrueを返す
    user_permission_lv = DISCORD_USERS.find(discord_id: @user_id).permission_level
    command_permission_lv = command.permission_level
    unless user_permission_lv >= command_permission_lv
      @error_message = "実行権限がありません\n
        > あなたの権限レベル：#{user_permission_lv}\n
        > コマンドの実行権限レベル：#{command_permission_lv}
      "
      return false
    end

    true
  end

  # 日本語文字をローマ字に変換する処理
  # @param [String] 変換対象の文字列
  # @return [String] ローマ字に変換した文字列
  def convert_en_to_ja(str_data)
    # 全ての文字が1バイト文字なら変換しない
    return str_data if str_data.chars.map{ |moji| moji.bytesize == 1 }.all?

    # 漢字が含まれている場合ひらがなに変換する
    str_data = str_data.to_kanhira if str_data.chars.map(&:is_kanji?).any?

    # かな/カナをローマ字に変換する
    str_data.to_roman
  end

  # minecraft rconへ認証する処理
  def authorize
    # すでにログイン済みの場合はtrueを返す
    return true if authorized?

    result = @transfer.authorize(PASSWORD)

    @authorized = result
  end

  # 認証済みかどうかを確認する処理
  # @return [Boolean]
  def authorized?
    @authorized
  end
end
