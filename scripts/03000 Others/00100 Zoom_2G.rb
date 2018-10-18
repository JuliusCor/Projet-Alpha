class Sprite_Character
  def zoom=(v)
    super(2 * v)
  end
  def zoom_x
    super / 2
  end
  # Initialize the shadow display
  def init_shadow
    @shadow = Sprite.new(self.viewport)
    @shadow.bitmap = bmp = RPG::Cache.character(Shadow_File)
    @shadow.src_rect.set(0,0, bmp.width / 4, bmp.height / 4)
    @shadow.ox = bmp.width / 8
    @shadow.oy = bmp.height / 4
    @shadow.zoom = 2
  end
end
class Game_Character
  # Return the x position of the shadow of the character on the screen
  # @return [Integer]
  def shadow_screen_x
    return ((@real_x - $game_map.display_x + 3) / 8 + 8) * 2
  end
  # Return the y position of the shadow of the character on the screen
  # @return [Integer]
  def shadow_screen_y
    return ((@real_y - $game_map.display_y + 3) / 8 + 17) * 2
  end
end
module Config
  remove_const :Specific_Zoom
  Specific_Zoom = 1
end
class Game_Map
  remove_const :CenterPlayer
  CenterPlayer = false
  # Scrolls the map down
  # @param distance [Integer] distance in y to scroll
  def scroll_down(distance)
    unless CenterPlayer
      @display_y = [@display_y + distance, (self.height - 7) * 128].min
    else
      @display_y = @display_y + distance
    end
  end
  # Scrolls the map right
  # @param distance [Integer] distance in x to scroll
  def scroll_right(distance)
    unless CenterPlayer
      @display_x = [@display_x + distance, (self.width - 10) * 128].min
    else
      @display_x = @display_x + distance
    end
  end
end
class Game_Player < Game_Character
  remove_const :CENTER_X
  remove_const :CENTER_Y
  # 4 time the x position of the Game_Player sprite
  CENTER_X = (160 - 16) * 4
  # 4 time the y position of the Game_Player sprite
  CENTER_Y = (144 - 16) * 4
  # Adjust the map display according to the given position
  # @param x [Integer] the x position on the MAP
  # @param y [Integer] the y position on the MAP
  def center(x, y)
    max_x = ($game_map.width - 10) * 128
    max_y = ($game_map.height - 7) * 128
    $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end
end
class Spriteset_Map
  # Tilemap initialization
  def init_tilemap
    # タイルマップを作成
    #>Adapter en fonction du jeu, sur Pokémon SDK 2x2 => 32x32
    tilemap_class = Tilemap
    if @tilemap.class != tilemap_class
      @tilemap.dispose if @tilemap
      @tilemap = tilemap_class.new(@viewport1)
    end
    @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
    7.times do |i|
      filename = $game_map.autotile_names[i] + '_._tiled'
      filename = $game_map.autotile_names[i] unless RPG::Cache.autotile_exist?(filename)
      @tilemap.autotiles[i] = RPG::Cache.autotile(filename)
    end
    @tilemap.map_data = $game_map.data
    @tilemap.priorities = $game_map.priorities
    @tilemap.reset
  end
end
class Tilemap
  remove_const :NX
  remove_const :NY
  # Number of tiles drawn on X axis
  NX = 12
  # Number of tiles drawn on Y axis
  NY = 12
end
module Yuki
  # MapLinker, script that emulate the links between maps. This script also display events.
  # @author Nuri Yuri
  module MapLinker
    remove_const :OffsetX
    remove_const :OffsetY
    # The offset in X until we see black borders
    OffsetX = 5
    # The offset in Y until we seen black borders
    OffsetY = 4
  end
end
module Yuki
  class Particle_Object
    def initialize(character,data,on_tp=false)
      @x=character.x
      @y=character.y
      @character=character
      @map_id=$game_map.map_id
      @sprite=::Sprite.new(Particles.viewport)
      @sprite.zoom = 2
      @data=data
      @counter=0
      @position_type=:center_pos
      @state=(on_tp ? :stay : :enter)
      @zoom = (zoom = ::Config::Specific_Zoom) ? zoom : ZoomDiv[1]#$zoom_factor.to_i]
      @add_z=@zoom
      @ox=0
      @oy=0
      @oy_off=0
    end
    # Execute an animation instruction
    # @param action [Hash] the animation instruction
    def exectute_action(action)
      if d=action[:state]
        @state = d
      end
      if d=action[:zoom]
        @sprite.zoom=d*2#$zoom_factor
      end
      if d=action[:file] #Choix d'un fichier
        @sprite.bitmap=RPG::Cache.particle(d)#Bitmap.new("Graphics/Particles/#{d}")
        @ox = (@sprite.bitmap.width*@sprite.zoom_x)/2
        @oy = (@sprite.bitmap.height*@sprite.zoom_y)/2
      end
      if d=action[:position]
        @position_type=d
      end
      if d=action[:angle]
        @sprite.angle=d
      end
      if d=action[:add_z]
        @add_z=d
      end
      if d=action[:oy_offset]
        @oy_off=d
      end
      if d=action[:opacity]
        @sprite.opacity=d
      end
      #DOIS ETRE A LA FIN !
      if d=action[:chara]
        cw=@sprite.bitmap.width/4
        ch=@sprite.bitmap.height/4
        sx = @character.pattern * cw
        sy = (@character.direction - 2) / 2 * ch
        @sprite.src_rect.set(sx,sy,cw,ch)
        @ox=(cw*@sprite.zoom_x)/2
        @oy=(ch*@sprite.zoom_y)/2
      end
      if d=action[:rect] #choix d'un src_rect
        @sprite.src_rect.set(*d)
        @ox = (d[2]*@sprite.zoom_x)/2
        @oy = (d[3]*@sprite.zoom_y)/2
      end
    end
  end
end