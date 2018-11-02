# Name Input scene
# @author Nuri Yuri
class Scene_NameInput
  # Character surface widths. Its a list of list of widthds by lines.
  RectWidths = [Array.new(12,20) + [50], Array.new(12,20) + [50], Array.new(12,20), Array.new(12,20), [105,105,105]]
  # List of character x coordinate
  X_Coords = [[],[],[],[],[]]
  # First x coordinate of each line
  Bases_X = [20, 20, 20, 20, 0]
  # Y coordinate of each line
  Bases_Y = [122, 122+32, 122+64, 122+96, 122+128]
  # Cursor name by character surface width
  Cursors = {20 => "NameInput_Selectcase", 105 => "NameInput_SelectSub", 
  105 => "NameInput_SelectSub", 105 => "NameInput_SelectSub"}
  #Gender
  Gender = ["battlebar_a", "battlebar_m", "battlebar_f"]
  # List of character when Name Input scene is in Maj state
  Chars_Maj = [
  ["&","[","+","-","*","/","=","%","(",")","]","$"],
  ["A","Z","E","R","T","Y","U","I","O","P","!",","],
  ["Q","S","D","F","G","H","J","K","L","M","Ç"," "],
  ["W","X","C","V","B","N","Ê","É","È","Ë"," "," "],
  ["MIN","EFF","FIN"]]
  # List of character when Name Input scene is in Minus state
  Chars_Min = [
  ["1","2","3","4","5","6","7","8","9","0","_","$"],
  ["a","z","e","r","t","y","u","i","o","p","?","."],
  ["q","s","d","f","g","h","j","k","l","m","ç"," "],
  ["w","x","c","v","b","n","ê","é","è","ë"," "," "],
  ["MAJ","EFF","FIN"]]
  # The space character
  Space = " "
  # Return the choosen name
  # @return [String]
  attr_reader :return_name
  # Create a new Scene_NameInput scene
  # @param default_name [String] the choosen name if no choice
  # @param max_lenght [Integer] the maximum number of characters in the choosen name
  # @param character [PFM::Pokemon, String, nil] the character to display
  include Text::Util
  include UI
  def initialize(default_name, max_length, character = nil, pokemon)
    @pokemon = pokemon
    @default_name = default_name
    @name = default_name.split(//)[0,max_length]
    @max_length = max_length
    @viewport = Viewport.create(:main, 20000)
    @background = Sprite.new(@viewport)
      .set_bitmap("NameInput_Fond", :interface)
    init_key_text
    init_input_chars
    init_text(0, @viewport)
    if(character.class == PFM::Pokemon)
      add_text(80, 32, 66, 19, @pokemon.name_upper).set_size(16)
      add_text(80, 64, 66, 19, "SURNOM?").set_size(16)
    else
      add_text(80, 32, 66, 19, "VOTRE NOM?").set_size(16)
    end
    @cursor = Sprite.new(@viewport)
    @compteur = 0
    @maj_c = Sprite::WithColor.new(@viewport)
      .set_position(-230, -200)
      .set_bitmap("NameInput_Selectentree", :interface)
      .set_color([1.0, 1.0, 1.0, 1.0])
    #> Sprite pokemon
    if(pokemon.class == PFM::Pokemon)
      character = sprintf("%03d%s_%d",@pokemon.id,@pokemon.shiny ? "s" : nil,@pokemon.form)
      @character = Sprite.new(@viewport)
      @character.bitmap = RPG::Cache.character(character)
      @character.set_position(32,22)
      @character.src_rect.set(0,0,16,20)
      @character.zoom = 2
      @Gender = Sprite.new(@viewport) #++++
      .set_position(16,30)
      @Gender.bitmap = RPG::Cache.interface(Gender[@pokemon.gender])
    else
      @character = Sprite.new(@viewport)
      if($game_switches[1] == true)
        @character.bitmap = RPG::Cache.character("000_Player_f")
      else
        @character.bitmap = RPG::Cache.character("000_Player_m")
      end
      @character.set_position(32,22)
      @character.src_rect.set(0,0,16,20)
      @character.zoom = 2
    end
    @counter = 0
    @frame = 0
    #
    @index_x = 0
    @index_y = 0
    @opacity = 0
  end
  
  def update
    @compteur += 1
    if(@compteur>5)
      @cursor.opacity = 0
    end
    if(@compteur>10)
      @cursor.opacity = 255
      @compteur = 0
    end
    #>Mise à jour de l'opacité du curseur
    op = @cursor.opacity
    @cursor.opacity += @opacity
    @opacity -= 2*@opacity if op == @cursor.opacity
    unless(@cursor.visible)
      return update_keyboard
    end
    #>Mise à jour des positions
    if(Input.repeat?(:UP))
      if(@index_x >= 0 and @index_x <= 3 and @index_y == 0)
        @index_x = 0
      elsif(@index_x >= 4 and @index_x <= 7 and @index_y == 0)
        @index_x = 1
      elsif(@index_x >= 8 and @index_x <= 11 and @index_y == 0)
        @index_x = 2
      elsif(@index_y == 4 and @index_x == 0 and @index_y == 4)
        @index_x = 2
      elsif(@index_y == 4 and @index_x == 1 and @index_y == 4)
        @index_x = 6
      elsif(@index_y == 4 and @index_x == 2 and @index_y == 4)
        @index_x = 10
      end
      @index_y = (@index_y - 1) % Bases_Y.size
      update_cursor
    elsif(Input.repeat?(:DOWN))
      if(@index_y == 4 and @index_x == 1 and @index_y == 3)
        @index_x = 3
      elsif(@index_x >= 0 and @index_x <= 3 and @index_y == 3)
        @index_x = 0
      elsif(@index_x >= 4 and @index_x <= 7 and @index_y == 3)
        @index_x = 1
      elsif(@index_x >= 8 and @index_x <= 11 and @index_y == 3)
        @index_x = 2
      elsif(@index_x >= 0 and @index_x <= 2 and @index_y == 4)
        if(@index_x == 0)
          @index_x = 2
        elsif(@index_x == 1)
          @index_x = 6
        elsif(@index_x == 2)
          @index_x = 10
        end
      end
      @index_y = (@index_y + 1) % Bases_Y.size
      update_cursor
    elsif(Input.repeat?(:RIGHT))
      if(@index_x == 11)
        @index_x = 0
      elsif(@index_y < 4)
        @index_x = (@index_x + 1) % RectWidths[@index_y].size
      end
      if(@index_x == 2 and @index_y == 4)
        @index_x = 0
      elsif(@index_y == 4)
        @index_x = (@index_x + 1) % RectWidths[@index_y].size
      end
      update_cursor
    elsif(Input.repeat?(:LEFT))
      if(@index_x == 0)
        if(@index_y == 4)
          @index_x = 2
        else
          @index_x = 11
        end
      else
        @index_x = (@index_x - 1) % RectWidths[@index_y].size
      end
      update_cursor
    elsif(Input.trigger?(:B))
      erase_char
    elsif(Input.trigger?(:A))
      if(@index_y == 4 and @index_x == 1)
        erase_char
      elsif(@index_y == 4 and @index_x == 2)
        validate
      elsif(@index_y == 2 and @index_x == 11)
        add_char(Space)
      elsif(@index_y == 3 and @index_x == 11)
        add_char(Space)
      elsif(@index_y == 4 and @index_x == 0)
          $game_system.se_play($data_system.decision_se)
          @maj_c.visible = !@maj_c.visible
          draw_chars
      else
        add_char(get_chars_arr[@index_y][@index_x])
        auto_set_validate
      end
    elsif(Input::Keyboard.press?(Input::Keyboard::RControl))
      unless @lastctrl
        @cursor.visible = false
        @lastctrl = true
      end
    else
      @lastctrl = false
    end
    @counter += 1
    if(@counter == 20)
      @frame += 1
      @counter = 0
    end
    @frame = 0 if(@frame > 3)
    @character.src_rect.set(0+16*@frame,0,16,20)
  end
  
  def update_cursor
    @cursor.x = X_Coords[@index_y][@index_x]
    @cursor.y = Bases_Y[@index_y]
    unless(@index_y==1 and @index_x==10)
      @cursor.bitmap = RPG::Cache.interface(Cursors[RectWidths[@index_y][@index_x]])
    else
      @cursor.bitmap = RPG::Cache.interface(Cursors[RectWidths[@index_y-1][@index_x]])
    end
  end
  
  def init_key_text
    chars = Chars_Maj
    @key_texts = Array.new(chars.size) do |i|
      x = Bases_X[i]
      y = Bases_Y[i] - Text::Util::FOY
      char_list = chars[i]
      rects = RectWidths[i]
      Array.new(char_list.size) do |j|
        X_Coords[i][j] = x
        width = rects[j]
        t = Text.new(0, @viewport, x, y, width, 30, char_list[j], 1).set_size(16)
        t.load_color(0) if width > 20
        x += width+4
        next(t)
      end
    end
  end
  
  def init_input_chars
    #x = (320 - 18 * @max_length)/2
    x = 78
    y = 96 - Text::Util::FOY
    bmp = RPG::Cache.interface("NameInput_Underscore")
    @input_texts = Array.new(@max_length)
    @input_underscore = Array.new(@max_length)
    @max_length.times do |i|
      @input_underscore[i] = Sprite.new(@viewport).set_bitmap(bmp).set_position(x, y)
      @input_texts[i] = Text.new(0, @viewport, x, y, 18, 16, nil.to_s, 1).load_color(0).set_size(16)
      x += 18
    end
  end
  
  # Draw the name
  def draw_name
    sz = @name.size
    @max_length.times do |i|
      @input_underscore[i].y = i == sz ? 108 : 102
      @input_underscore[i].opacity = 255
      i < sz ? @input_underscore[i].opacity = 0 : 255
      text = @input_texts[i]
      c = @name[i].to_s
      text.text = c if c != text.text
    end
  end
  
end
