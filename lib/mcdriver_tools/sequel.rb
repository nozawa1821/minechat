# DBへの接続
begin
  # タイムゾーンの設定
  Sequel.default_timezone = :local

  Sequel.sqlite(Config::MINECHAT_DB)
rescue Sequel::DatabaseConnectionError => e
  msg = "\e[31mDBアクセスに失敗しました\e[0m"
  puts msg
  raise e
end

# discord user管理用(内部DB)クラス
class DISCORD_USERS < Sequel::Model(:discord_users)
  plugin :timestamps, update_on_create: true

  # 登録されているユーザーを一覧表示
  # @return [Array<Hash>]
  def self.list
    self.all.map { |record| {id: record[:discord_id].to_i, name: record[:user_name], permission_level: record[:permission_level]} }
  end

  # ユーザーの追加
  # @return [DISCORD_USERS] 追加されたユーザーのオブジェクト
  def self.add_user(id, name, owner = false)
    permission_level = owner ? 4 : 0

    self.insert(discord_id: id, user_name: name, permission_level: permission_level)
    self.find(discord_id: id)
  end

  # ユーザーの権限を変更
  # @return [DISCORD_USERS] 権限変更されたユーザーのオブジェクト
  # @return [nil] ユーザーが見つからない場合、ユーザーの権限が変更できない場合はnil
  def self.chmod(user_id, permission_level)
    target_user = self.find(discord_id: user_id)
    target_user.update(permission_level: permission_level) if target_user.present?
  end

  # userが既に登録済みかを確認
  # @return [bool] 登録済みの場合はtrueを返す
  def self.registed?(user_id)
    self.find(discord_id: user_id).present?
  end
end

# コマンドリスト(内部DB)のクラス
class COMMANDS < Sequel::Model(:commands)
  plugin :timestamps, update_on_create: true

  # 登録されているコマンドを一覧表示
  # @return [Array<Hash>]
  def self.list
    self.all.map { |record| {id: record[:id], name: record[:command_name], permission_level: record[:permission_level]} }
  end

  # コマンドの追加
  def self.add(command_name, permission_level)
    self.insert(command_name: command_name, permission_level: permission_level)
    self.find(command_name: command_name)
  end

  # コマンドの権限を変更
  def self.chmod(command_name, permission_level)
    target_command = self.find(command_name: command_name)
    target_command.update(permission_level: permission_level) if target_command.present?
  end

  # コマンドの削除
  def self.remove(command_name)
    target_command = self.find(command_name: command_name)
    target_command.delete if target_command.present?
  end

  # コマンドが既に登録済みかを確認
  # @return [bool] 登録済みの場合はtrueを返す
  def self.command?(command_name)
    self.find(command_name: command_name).present?
  end
end
