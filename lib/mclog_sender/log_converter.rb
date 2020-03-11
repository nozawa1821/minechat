class LogConverter
  DEATH_REGEXP = {
    shot_by_aroow: /^(?<user>.*) was shot by arrow$/,
    shot_by_player_using_tool: /^(?<user>.*) was shot by (?<by>.*) using (?<tool>.*)$/,
    shot_by_player: /^(?<user>.*) was shot by (?<by>.*)$/,
    picked: /^(?<user>.*) was pricked to death$/,
    hugged_by_cactus: /^(?<user>.*) hugged a cactus$/,
    hugged_by_cactus_esc_player: /^(?<user>.*) walked into a cactus while trying to escape (?<by>.*)$/,
    stabbed: /^(?<user>.*) was stabbed to death$/,
    drowned: /^(?<user>.*) drowned$/,
    drowned_esc_player: /^(?<user>.*) drowned whilst trying to escape (?<by>.*)$/,
    suffocated: /^(?<user>.*) suffocated in a wall$/,
    squished: /^(?<user>.*) was squished too much$/,
    kinetic_energy: /^(?<user>.*) experienced kinetic energy$/,
    removed_elytra: /^(?<user>.*) removed an elytra while flying$/,
    blew_up: /^(?<user>.*) blew up$/,
    blown_up: /^(?<user>.*) was blown up by (?<by>.*)$/,
    killed: /^(?<user>.*) was killed by (?<by>.*)$/,
    hit_the_ground: /^(?<user>.*) hit the ground too hard$/,
    fell_from_high_place: /^(?<user>.*) fell from a high place$/,
    fell_off_ladder: /^(?<user>.*) fell off a ladder$/,
    fell_off_vines: /^(?<user>.*) fell off some vines$/,
    fell_out_water: /^(?<user>.*) fell out of the water$/,
    fell_into_fire: /^(?<user>.*) fell into a patch of fire$/,
    fell_into_cactus: /^(?<user>.*) fell into a patch of cacti$/,
    doomed: /^(?<user>.*) was doomed to fall by (?<by>.*)$/,
    shot_off_some_vines_by_player: /^(?<user>.*) was shot off some vines by (?<by>.*)$/,
    shot_off_some_ladder_by_player: /^(?<user>.*) was shot off a ladder by (?<by>.*)$/,
    blown_from_high_place_by_player: /^(?<user>.*) was blown from a high place by (?<by>.*)$/,
    squashed_by_falling_anvil: /^(?<user>.*) was squashed by a falling anvil$/,
    squashed_by_falling_block: /^(?<user>.*) was squashed by a falling block$/,
    went_up_in_flames: /^(?<user>.*) went up in flames$/,
    burned_to_death: /^(?<user>.*) burned to death$/,
    burnt_to_fighting_player: /^(?<user>.*) was burnt to a crisp whilst fighting (?<by>.*)$/,
    into_fire_to_fighting_player: /^(?<user>.*) walked into a fire whilst fighting (?<by>.*)$/,
    bang: /^(?<user>.*) went off with a bang$/,
    lava: /^(?<user>.*) tried to swim in lava$/,
    lava_esc_player: /^(?<user>.*) tried to swim in lava while trying to escape (?<by>.*)$/,
    lightning: /^(?<user>.*) was struck by lightning$/,
    floor_lava: /^(?<user>.*) discovered floor was lava$/,
    slain_using_tool_by: /^(?<user>.*) was slain by (?<by>.*) using (?<tool>.*)$/,
    slain_by: /^(?<user>.*) was slain by (?<by>.*)$/,
    finished_off_using_tool_by: /^(?<user>.*) got finished off by (?<by>.*) using (?<tool>.*)$/,
    finished_off_by: /^(?<user>.*) got finished off by (?<by>.*)$/,
    fireballed: /^(?<user>.*) was fireballed by (?<by>.*)$/,
    killed_by_magic: /^(?<user>.*) was killed by magic$/,
    killed_by_player_using_magic: /^(?<user>.*) was killed by (?<by>.*) using magic$/,
    starved: /^(?<user>.*) starved to death$/,
    caunter_killed_by_player: /^(?<user>.*) was killed while trying to hurt (?<by>.*)$/,
    impaled_by_player: /^(?<user>.*) was impaled by (?<by>.*)$/,
    fell_out_of_the_world: /^(?<user>.*) fell out of the world$/,
    fell_out_of_the_world_from_high: /^(?<user>.*) fell from a high place and fell out of the world$/,
    didnt_want_to_live: /^(?<user>.*) didn't want to live in the same world as (?<by>.*)$/,
    withered_away: /^(?<user>.*) withered away$/,
    pummeled_by_player: /^(?<user>.*) was pummeled by (?<by>.*)$/,
    died: /^(?<user>.*) died$/,
  }

  def initialize(log_message)
    @log = log_message
  end

  def start
    # 文字列が正規表現にマッチするかを確認
    match_result = DEATH_REGEXP.values.find_index {|legexp| @log.match(legexp) }

    # マッチしない場合はnilを返す
    return nil if match_result.nil?

    # マッチした場合、文字列を変換する
    log_keyname = DEATH_REGEXP.keys[match_result]
    match_msg = @log.match(DEATH_REGEXP[log_keyname])
    convert_log_message(log_keyname, match_msg.named_captures)
  end

  def convert_log_message(log_keyname, matched_log)
    # ハッシュのキーをシンボル化
    matched_log = symbolize_keys(matched_log)

    # 設定された言語に変換
    I18n.t("death.#{log_keyname}", user: matched_log[:user], by: matched_log[:by], tool: matched_log[:tool])
  end

  # ハッシュのキーをシンボル化
  def symbolize_keys(hash)
    hash.map{|k,v| [k.to_sym, v] }.to_h
  end
end