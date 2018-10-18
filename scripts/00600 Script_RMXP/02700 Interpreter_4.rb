=begin
#==============================================================================
# ■ Interpreter (分割定義 4)
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_System クラ
# スや Game_Event クラスの内部で使用されます。
#==============================================================================

class Interpreter

  def command_122
    # 値を初期化
    value = 0
    # オペランドで分岐
    case @parameters[3]
    when 0  # 定数
      value = @parameters[4]
    when 1  # 変数
      value = $game_variables[@parameters[4]]
    when 2  # 乱数
      value = @parameters[4] + rand(@parameters[5] - @parameters[4] + 1)
    when 3  # アイテム
      value = $game_party.item_number(@parameters[4])
    when 4  # アクター
      actor = $game_actors[@parameters[4]]
      if actor != nil
        case @parameters[5]
        when 0  # レベル
          value = actor.level
        when 1  # EXP
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # SP
          value = actor.sp
        when 4  # MaxHP
          value = actor.maxhp
        when 5  # MaxSP
          value = actor.maxsp
        when 6  # 腕力
          value = actor.str
        when 7  # 器用さ
          value = actor.dex
        when 8  # 素早さ
          value = actor.agi
        when 9  # 魔力
          value = actor.int
        when 10  # 攻撃力
          value = actor.atk
        when 11  # 物理防御
          value = actor.pdef
        when 12  # 魔法防御
          value = actor.mdef
        when 13  # 回避修正
          value = actor.eva
        end
      end
    when 5  # エネミー
      enemy = $game_troop.enemies[@parameters[4]]
      if enemy != nil
        case @parameters[5]
        when 0  # HP
          value = enemy.hp
        when 1  # SP
          value = enemy.sp
        when 2  # MaxHP
          value = enemy.maxhp
        when 3  # MaxSP
          value = enemy.maxsp
        when 4  # 腕力
          value = enemy.str
        when 5  # 器用さ
          value = enemy.dex
        when 6  # 素早さ
          value = enemy.agi
        when 7  # 魔力
          value = enemy.int
        when 8  # 攻撃力
          value = enemy.atk
        when 9  # 物理防御
          value = enemy.pdef
        when 10  # 魔法防御
          value = enemy.mdef
        when 11  # 回避修正
          value = enemy.eva
        end
      end
    when 6  # キャラクター
      character = get_character(@parameters[4])
      if character != nil
        case @parameters[5]
        when 0  # X 座標
          value = character.x - ::Yuki::MapLinker::OffsetX
        when 1  # Y 座標
          value = character.y - ::Yuki::MapLinker::OffsetY
        when 2  # 向き
          value = character.direction
        when 3  # 画面 X 座標
          value = character.screen_x
        when 4  # 画面 Y 座標
          value = character.screen_y
        when 5  # 地形タグ
          value = character.terrain_tag
        end
      end
    when 7  # その他
      case @parameters[4]
      when 0  # マップ ID
        value = $game_map.map_id
      when 1  # パーティ人数
        value = $game_party.actors.size
      when 2  # ゴールド
        value = $game_party.gold
      when 3  # 歩数
        value = $pokemon_party.steps
      when 4  # プレイ時間
        value = Graphics.frame_count / 60#Graphics.frame_rate
      when 5  # タイマー
        value = $game_system.timer / 60#Graphics.frame_rate
      when 6  # セーブ回数
        value = $game_system.save_count
      end
    end
    # 一括操作のためにループ
    for i in @parameters[0] .. @parameters[1]
      # 操作で分岐
      case @parameters[2]
      when 0  # 代入
        $game_variables[i] = value
      when 1  # 加算
        $game_variables[i] += value
      when 2  # 減算
        $game_variables[i] -= value
      when 3  # 乗算
        $game_variables[i] *= value
      when 4  # 除算
        if value != 0
          $game_variables[i] /= value
        end
      when 5  # 剰余
        if value != 0
          $game_variables[i] %= value
        end
      end
      # 上限チェック
      if $game_variables[i] > 99999999
        $game_variables[i] = 99999999
      end
      # 下限チェック
      if $game_variables[i] < -99999999
        $game_variables[i] = -99999999
      end
    end
    # マップをリフレッシュ
    $game_map.need_refresh = true
    # 継続
    return true
  end
  
end
=end