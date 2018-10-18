module UI
  # Button that show basic information of a Pokemon
  class TeamButton < SpriteStack
    # Get the Item text to perform specific operations
    # @return [SymText]
    attr_reader :item_text
    # List of the Y coordinate of the button (index % 6), relative to the contents definition !
    CoordinatesY = [0, 34*1, 34*2, 34*3, 34*4, 34*5]
    # List of the X coordinate of the button (index % 2), relative to the contents definition !
    CoordinatesX = [0, 0]
    # Get the selected state of the sprite
    # @return [Boolean]
    attr_reader :selected
    # Create a new Team button
    # @param viewport [LiteRGSS::Viewport] viewport where to show the button
    # @param index [Integer] Index of the button in the team
    def initialize(viewport, index)
      @index = index
      super(viewport, CoordinatesX[index % 2], CoordinatesY[index % 6])
      @pokeicon = push(48, 16, nil, type: PokemonIconSprite)
      @pokeicon.zoom = 2
      add_text(53, 0, 100, 16, :given_name_upper, type: SymText)
      @hp = push_sprite(UI::Bar.new(viewport, @x + 214, @y + 24, RPG::Cache.interface("team/HPBars"), 96, 4, 0, 0, 3))
      push(182, 20, "team/hpbars_frame")
      add_text(220, 0, 100, 16, :hp_pokemon_given, 2, type: SymText)
      add_text(170, 0, 100, 16, "/", 2)
      add_text(152, 0, 100, 16, :hp_pokemon_max, 2, type: SymText)
      #@font_id = 20 # trick to get SmallGreen
      #add_text(200+1000, 100, 100, 16, :hp_text, 2, type: SymText)
      #@font_id = 0
      #push(53, 14, nil, type: GenderSprite)
      push(16, 18, "team/Item", type: HoldSprite)
      @n = push(135, 22, "team/level_n")
      add_text(80, 18, 100, 16, :level_pokemon_number, 2, type: SymText)
      push(85, 18, nil, type: StatusSprite)
      @item_sprite = push(2400, 39, "team/But_Object", 1, 2, type: SpriteSheet)
      @item_text = add_text(2700, 40, 113, 16, :item_name, type: SymText)
      hide_item_name
      @selected = false
      @frameicon = 0
      update
    end
    
    def update
      if(@frameicon >= 20)
        @pokeicon.src_rect.set(0,0,16,16)
        @frameicon = 0
      elsif(@frameicon == 10)
        @pokeicon.src_rect.set(16,0,16,16)
      end
      @frameicon += 1
    end
  
    # Set the data of the SpriteStack
    # @param _data [PFM::Pokemon]
    def data=(_data)
      super(_data)
      @hp.rate = _data.hp_rate
      @level_pokemon = _data.level
      @item_text.visible = @item_sprite.visible
      if(@level_pokemon > 99 )
        @n.x = 121
      elsif(@level_pokemon < 10 )
        @n.x = 150
      else
        @n.x = 135
      end
    end

    # Set the selected state of the sprite
    # @param v [Boolean]
    def selected=(v)
      @selected = v
      @item_sprite.sy = v ? 1 : 0
      @item_text.load_color(v ? 9 : 0)
    end
    
    # Show the item name
    def show_item_name
      @item_sprite.visible = @item_text.visible = true
    end
    
    # Hide the item name
    def hide_item_name
      @item_sprite.visible = @item_text.visible = false
    end
    
    # Refresh the button
    def refresh
      self.data = @data
    end

  end
end