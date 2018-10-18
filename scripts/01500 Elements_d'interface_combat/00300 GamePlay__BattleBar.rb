module GamePlay
  # Object that show the Battle Bar of a Pokemon in Battle
  class BattleBar < UI::SpriteStack
    # Files used to show a bar
    Files = ["battlebar_actor","battlebar_enemy"]
    # Normal position of actor bars
    A_Pos = [[600,600],[600,600], [144,146]]
    #>Positions normales des barres Enemis
    E_Pos = [[600,600],[600,600], [18, 32]]
    # Gets the pokemon associated to the bar
    attr_reader :pokemon
    include UI
    # Create a new Battle Bar
    # @param viewport [LiteRGSS::Viewport]
    # @param pokemon [PFM::Pokemon]
    def initialize(viewport, pokemon)
      super(viewport)
      @background = push(0, 0, nil)
      @got = push(0, 0, "battlebar_get")
      @gender = push(0, 0, nil, type: GenderSprite)
      @status = push(0, 0, nil, type: StatusSprite)
      @name =  add_text(0, 0, 0, 16, :given_name,type: SymText, color: 0).set_size(16)
      @name_en =  add_text(0, 0, 0, 16, :given_name,type: SymText, color: 0).set_size(16)
      @n = push(0, 0, "level_n")
      @level = add_text(0, 0, 32, 16, :level_pokemon_number,2, type: SymText, color: 0).set_size(16)
      @hp_bar = push_sprite Bar.new(viewport, 0, 0, RPG::Cache.interface("battlebar_hp"), 96, 4, 0, 0, 6)
      @hp_text = add_text(0, 0, 68, 16, :hp_text, 1, type: SymText, color: 0).set_size(16)
      @exp_bar = push_sprite Bar.new(viewport, 0, 0, RPG::Cache.interface("battlebar_exp"),128, 4, 0, 0, 1)
      self.pokemon = pokemon
    end
    # Refresh the bar contents
    def refresh
      if @pokemon and !pokemon.dead?
        self.data = @pokemon
        @hp_bar.visible = @background.visible = true
        @pokemon.position < 0 ? refresh_enemy : refresh_actor
      else
        self.visible = false
      end
    end
    # Refresh the bar contents when it's an enemy bar
    def refresh_enemy
      @hp_bar.rate = @pokemon.hp_rate
      @hp_text.visible = @exp_bar.visible = false
      @name.visible = false
      @got.visible = $pokedex.has_captured?(@pokemon.id)
      if(pokemon.status>0)
        @level.visible = false
        @n.visible = false
      end
    end
    # Refresh the bar contents when it's an actor bar
    def refresh_actor
      @hp_bar.rate = @pokemon.hp_rate
      #@exp_bar.rate = @pokemon.exp_rate
      @exp_bar.rate = 1 - @pokemon.exp_rate
      @hp_text.visible = @exp_bar.visible = true
      @name_en.visible = false
      @got.visible = false
    end
    # Sets the Pokémon shown by this bar
    # @param v [PFM::Pokemon]
    def pokemon=(v)
      self.data = @pokemon = v
      refresh
      return unless pokemon and !pokemon.dead?
      ajust_position
    end
    # Adjust the position of the bar on the screen
    def ajust_position
      @x = @y = 0
      if(@pokemon.position < 0)
        pos = E_Pos
        index = $game_temp.vs_type == 2 ? -@pokemon.position - 1 : 2
        adjust_position_enemy
      else
        pos = A_Pos
        index = $game_temp.vs_type == 2 ? @pokemon.position : 2
        adjust_position_actor
      end
      set_position(pos[index][0], pos[index][1])
      self.z = 10038 + @pokemon.position*2
    end
    # Adjust the position of the sprites when the bar is for an enemy
    def adjust_position_enemy
      @background.set_position(0, 0)
        .set_bitmap(Files[1], :interface)
      @gender.set_position(126, -18)
      @name_en.set_position(0, -34)
      @level.set_position(76, -18)
      @hp_bar.set_position(46, 6)
      @status.set_position(62, -16)
      @got.set_position(-2, -14)
      if(@pokemon.status>0)
        @level.visible = false
        @n.visible = false
      else
        @level.visible = true
        @n.visible = true
      end
      if(@pokemon.level>99)
        @n.visible = false
      elsif(@pokemon.level>9)
        @n.visible = true
        @n.set_position(65, -12)
      else(@pokemon.level<10)
        @n.visible = true
        @n.set_position(80, -12)
      end
    end
    # Adjust the position of the sprites when the bar is for an actor
    def adjust_position_actor
      @background.set_position(0, 0)
        .set_bitmap(Files[0], :interface)
      @gender.set_position(128, -18)
      @name.set_position(16, -34)
      @level.set_position(94, -18)
      @hp_bar.set_position(48, 4)
      @hp_text.set_position(55, 12)
      @exp_bar.set_position(16, 36)
      @status.set_position(80, -16)
      if(@pokemon.status>0)
        @level.visible = false
        @n.visible = false
      else
        @level.visible = true
        @n.visible = true
      end
      if(@pokemon.level>99)
        @n.visible = false
      elsif(@pokemon.level>=10)
        @n.visible = true
        @n.set_position(83, -12)
      else(@pokemon.level<=9)
        @n.visible = true
        @n.set_position(98, -12)
      end
    end
    # Tells the bar to go out of the screen
    # @param frame [Integer] number of frame
    # @return [self]
    def go_out(frame = 10)
      return self unless @pokemon and pokemon.position
      if(@pokemon.position < 0)
        move_to(-@stack.first.bitmap.width, self.y, frame)
      else
        move_to(320, self.y, frame)
      end
      return self
    end
    # Tells the bar to come back on the screen
    # @param frame [Integer] number of frame
    # @return [self]
    def come_back(frame = 10)
      return self unless @pokemon and !pokemon.dead?
      if(@pokemon.position < 0)
        pos = E_Pos
        index = $game_temp.vs_type == 2 ? -@pokemon.position - 1 : 2
        self.x = -@stack.first.bitmap.width
      else
        pos = A_Pos
        index = $game_temp.vs_type == 2 ? @pokemon.position : 2
        self.x = 320
      end
      move_to(pos[index][0], self.y, frame)
      return self
    end
  end
end