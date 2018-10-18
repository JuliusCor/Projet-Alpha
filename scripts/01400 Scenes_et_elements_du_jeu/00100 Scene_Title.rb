# The title screen scene
class Scene_Title
  Background = ["fond_0","fond_1","fond_2","fond_3"]
  Splash = ["white_background","black_background","splash"]
  # Entry point of the scene. If player hit X + B + UP the GamePlay::Load scene will ask the save deletion.
  def main
    data_load
    GamePlay::Save.load
    title_animation
    if $scene == self
      Yuki::MapLinker.reset
      GamePlay::Load.new(#> Suppression de sauvegarde : X+B+Haut
        Input.press?(:X) &
        Input.press?(:B) &
        Input.press?(:UP)).main
    end
  end
  # Show the title animation
  def title_animation
    @loop = true
    while @loop and $scene == self
      init_sprites
      play_intro
      init_title
      play_title
      dispose_sprites
    end
    RPG::Cache.load_title(true)
    GC.start
  end
  # Init the title screen sprites
  def init_sprites
    @viewport = Viewport.create(:main, 100)
    #@viewport.tone.set(-255, -255, -255, 0)
    #@viewport.color.set(0, 0, 0, 255)
    @main_sprite = Sprite.new(@viewport)
    @main_sprite.z = 0
    @start_sprite = Sprite.new(@viewport)
    @start_sprite.z = 1
    @main_sprite.bitmap = RPG::Cache.title(Splash[0])
    @frame = 0
  end
  # Dispose the title screen sprites
  def dispose_sprites
    Graphics.freeze
    @main_sprite.dispose
    @viewport.dispose
    @main_sprite = @viewport = nil
  end
  # Init the title display part
  def init_title
    Graphics.freeze
    @viewport.color.alpha = 0
    #@viewport.tone.set(0,0,0,0)
    @fnt = rand(3)
    @main_sprite.bitmap = RPG::Cache.title(Background[0])
    @counter = 0
    Graphics.transition
  end
  # Play the splash part
  def play_intro
    Graphics.transition
    #Audio.se_play("Audio/SE/2G_Nintendo")
    count = 130
    (count).times do |i|
      @main_sprite.bitmap = RPG::Cache.title(Splash[1]) if(i == 26)
      @main_sprite.bitmap = RPG::Cache.title(Splash[2]) if(i == 38)
      @main_sprite.bitmap = RPG::Cache.title(Splash[1]) if(i == 120)
      Graphics.update
    end
  end
  # Play the title display part
  def play_title
    Audio.bgm_play("Audio/BGM/2G_Title_Crystal")
    until Input.trigger?(:A) or Input.trigger?(:X) or Mouse.trigger?(:left)
      if(@counter += 1) == 10
        @counter = 0
        @frame += 1
        @frame = 0 if(@frame >=4)
        @main_sprite.bitmap = RPG::Cache.title(Background[@frame])
      end
      Graphics.update
      if Audio.bgm_position > 2841930 or $scene != self
        Audio.bgm_stop
        return
      end
    end
    $game_system.se_play($data_system.decision_se)
    @loop = false
    Audio.bgm_stop
  end
  # Load the RMXP Data
  def data_load
    unless $data_actors
      $data_actors        = _clean_name_utf8(load_data("Data/Actors.rxdata"))
      $data_classes       = _clean_name_utf8(load_data("Data/Classes.rxdata"))
      #$data_skills        = load_data("Data/Skills.rxdata")
      #$data_items         = load_data("Data/Items.rxdata")
      #$data_weapons       = load_data("Data/Weapons.rxdata")
      #$data_armors        = load_data("Data/Armors.rxdata")
      $data_enemies       = _clean_name_utf8(load_data("Data/Enemies.rxdata"))
      $data_troops        = _clean_name_utf8(load_data("Data/Troops.rxdata"))
      #$data_states        = load_data("Data/States.rxdata")
      #$data_animations    = load_data("Data/Animations.rxdata")
      $data_tilesets      = _clean_name_utf8(load_data("Data/Tilesets.rxdata"))
      $data_common_events = _clean_name_utf8(load_data("Data/CommonEvents.rxdata"))
      $data_system        = load_data_utf8("Data/System.rxdata")
    end
    $game_system = Game_System.new
    $game_temp = Game_Temp.new
  end
end