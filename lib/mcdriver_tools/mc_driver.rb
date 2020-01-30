class MCDriver
  HOST = Config::MINECRAFT[:host]
  PORT = Config::MINECRAFT[:rcon_port]
  PASSWORD = Config::MINECRAFT[:rcon_password]
  COMMAND_LIST = YAML.load_file('config/command_list.yml')

  def initialize
    @authorized = false
    @transfer = CommandTransfer.new(HOST, PORT)
  end

  # 内容をminecraftのチャットに送信する処理
  def send(message)
    # 認証処理
    authorize

    # 内容が送信できない場合、送信処理を実行しない
    return false unless message_check(message)
    # 内容をminecraftのコマンドに変換する
    message = create_chat_messge(message)

    # minecraft serverにコマンドを送信する
    response = @transfer.send(message)

    # レスポンス内容をコンソール上に表示する
    p response

    return true
  end

  private

  # サーバに送信できる内容か検閲する
  def message_check(message)
    # コマンドを切り抜き
    match_data = message.match(/^\/(\w+)/)

    # 内容がコマンド形式になっていなければtrueを返す
    return true unless !!match_data

    # 実行可能コマンドリストにコマンドがあればtrueを返す
    COMMAND_LIST.any?(match_data[1])
  end

  # 内容をコマンド形式に変換する処理
  def create_chat_messge(message)
    # コマンド形式であればそのまま内容を返却する
    return message if !!message.match(/^\//)

    # 内容がコマンド形式で記述されていない場合はsayコマンドを実行する
    "/say #{message}"
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
