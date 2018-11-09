# Disable shadow processing
Text::Util.send :remove_const, :DEFAULT_OUTILINE_SIZE
Text::Util::DEFAULT_OUTILINE_SIZE = 0

# Disable 1x1 tilemap to keep 2x2 tilemap
Object.send :remove_const, :Yuri_Tilemap
Yuri_Tilemap = Tilemap

# Make the Tilemap viewport display with a little offset
class Spriteset_Map
  alias psdk_initialize initialize
  # Initialize a new Spriteset_Map object
  # @param zone [Integer, nil] the id of the zone where the player is
  def initialize(zone = nil)
    psdk_initialize(zone)
    @viewport1.rect.set(0, nil, 512)
    @viewport2.rect.set(0, nil, 512)
    @viewport3.rect.set(0, nil, 512)
  end
end
# Adjust the tilemap related constants
Tilemap.send :remove_const, :NX
Tilemap.send :remove_const, :NY
Tilemap::NX = 12
Tilemap::NY = 12
Yuki::MapLinker.send :remove_const, :OffsetX
Yuki::MapLinker.send :remove_const, :OffsetY
Yuki::MapLinker::OffsetX = 5
Yuki::MapLinker::OffsetY = 4
Game_Player.send :remove_const, :CENTER_X
Game_Player.send :remove_const, :CENTER_Y
Game_Player::CENTER_X = (160 - 16) * 4
Game_Player::CENTER_Y = (144 - 16) * 4

# Adjust character shadow
class Sprite_Character
  # Force zoom to 1
  # @param value [Numeric] desired zoom
  def zoom=(value)
    super(2 * value)
  end
  
  def update
    #>On update RPG::Sprite uniquement si il y a une animation.
    super if @_animation or @_loop_animation
    # Vérification du changement de character
    if @character_name != @character.character_name or @tile_id != @character.tile_id
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      if(@tile_id >= 384)
        self.bitmap = RPG::Cache.tileset($game_map.tileset_name)
        tile_id = @tile_id - 384
        self.src_rect.set(tile_id % 8 * 32, tile_id / 8 * 32, 32, @height = 32)
        self.zoom = 0.5#_x=self.zoom_y=(16*$zoom_factor)/32.0
        self.ox = 16
        self.oy = 32
        @ch = 32
      else
        self.bitmap = RPG::Cache.character(@character_name, 0)
        @cw = bitmap.width / 4
        @height = @ch = bitmap.height / 4
        self.ox = @cw / 2
        self.oy = @ch
        self.zoom = 1 if self.zoom_x != 1
        self.src_rect.set(@character.pattern * @cw, (@character.direction - 2) / 2 * @ch, 
        @cw, @ch)
        @pattern = @character.pattern
        @direction = @character.direction
      end
    end
    # Position du chara sur l'écran
    _x = self.x = @character.screen_x / @zoom
    y = @character.screen_y
    if add = @character.in_swamp
      y += add == 1 ? 4 : 8
    end
    _y = self.y = y / @zoom
    # Pseudo anti-lag
    _x -= self.ox
    _y -= self.oy
    rc = self.viewport.rect
    if _x > rc.width or _y > rc.height + 16 or (_x + self.width) < 0 or (_y + self.height) < 0
      @shadow.visible = false if @shadow
      return self.visible = false
    else
      self.visible = true
    end
    #Modification du morceau du character à afficher
    if(@tile_id == 0)
      eax = @character.pattern
      if(@pattern != eax)
        self.src_rect.x = eax*@cw
        @pattern = eax
      end
      eax=@character.direction
      if(@direction != eax)
        self.src_rect.y=(eax - 2) / 2 * @ch
        @direction=eax
      end
    end
    # Superiorité
    self.z = (@character.screen_z(@ch) + @add_z)# / @zoom
    # Modification des propriétés d'affichage
#    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    #>Devons nous supprimer la transparence du héros ? 
    #Ca aurait très bien pu être fait avec l'opacité, 
    #c'est con d'utiliser un truc qui touche uniquement le héros sur tous les charas :/
    self.opacity = (@character.transparent ? 0 : @character.opacity)
    # Animation
    if @character.animation_id != 0
      $data_animations    = load_data("Data/Animations.rxdata") unless $data_animations
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
     
    update_bush_depth if @bush_depth > 0
    update_shadow if @shadow
  end
end

module Config
  remove_const :Specific_Zoom
  Specific_Zoom = 1
end
# Adjust the character x/y positions
class Game_Character
  # Return the x position of the sprite on the screen
  # @return [Integer]
  def screen_x
    # 実座標とマップの表示位置から画面座標を求める
    return (@real_x - $game_map.display_x + 3) / 4 + 16 # +3 => +5
  end
  # Return the y position of the sprite on the screen
  # @return [Integer]
  def screen_y
    # 実座標とマップの表示位置から画面座標を求める
    y = (@real_y - $game_map.display_y + 3) / 4 + 32 # +3 => +5
    # ジャンプカウントに応じて Y 座標を小さくする
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end
  # Return the x position of the shadow of the character on the screen
  # @return [Integer]
  def shadow_screen_x
    return (@real_x - $game_map.display_x + 3) / 4 + 16 # +3 => +5
  end
  # Return the y position of the shadow of the character on the screen
  # @return [Integer]
  def shadow_screen_y
    return (@real_y - $game_map.display_y + 3) / 4 + 34 # +3 => +5
  end
end