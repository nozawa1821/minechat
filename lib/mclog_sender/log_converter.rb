class LogConverter
  def initialize(log_message)
    @log = log_message

    death_regexp = LogRegexpList::DEATH_REGEXP
    server_info_regexp = LogRegexpList::SERVER_INFO_REGEXP
    @log_regexps = [server_info_regexp, death_regexp]
  end

  def start
    result = nil

    @log_regexps.each do |regexps|
      # 文字列が正規表現にマッチするかを確認
      match_result = regexps.values.find_index {|regexp| @log.match(regexp) }

      # マッチしない場合はnilを返す
      next if match_result.nil?

      # マッチした場合、文字列を変換する
      log_keyname = regexps.keys[match_result]
      match_msg = @log.match(regexps[log_keyname])
      result = convert_log_message(regexps[:role], log_keyname, match_msg.named_captures)
    end

    result
  end

  def convert_log_message(role, log_keyname, matched_log)
    # ハッシュのキーをシンボル化
    matched_log = symbolize_keys(matched_log)

    # 設定された言語に変換
    I18n.t("#{role}.#{log_keyname}", user: matched_log[:user], by: matched_log[:by], tool: matched_log[:tool], info: matched_log[:info])
  end

  # ハッシュのキーをシンボル化
  def symbolize_keys(hash)
    hash.map{|k,v| [k.to_sym, v] }.to_h
  end
end
