module GamePlay
  # Class that shows the Pokedex
  class Dex < Base
    Background = ["Background","Background2","Background3"]
    # Text format for the name
    NameStr="%03d - %s"
    # Text format for the weight
    WeightStr="Poids : %.2f Kg"
    # Text format for the height
    HeightStr="Taille : %.2f m"
    include UI
    # Create a new Pokedex interface
    # @param page_id [Integer, false] id of the page to show
    def initialize(page_id = false)
      super()
      @viewport = Viewport.create(:main, 0)
      @descr_viewport = Viewport.create(18, 168, 320, 100)
      @pokemon_descr = Text.new(0, @descr_viewport, 0, 0, 300, 32, nil.to_s).load_color(3)
      @background = Sprite.new(@viewport).set_bitmap(Background[0], :pokedex)
      # Liste
      @list = Array.new(8) { |i| DexButton.new(@viewport, i) }
      @pokemonlist = PFM::Pokemon.new(0, 1)
      # Scrool
      # Frame
      @upbar = Sprite.new(@viewport).set_bitmap("up_bar", :pokedex)
      @arrow = Sprite.new(@viewport).set_bitmap("Selector", :pokedex).set_position(126, 12)
      @pokeface = DexWinSprite.new(@viewport)
      # Num generation
      @seen_got = DexSeenGot.new(@viewport)
      # Info
      @pokemon_info = DexWinInfo.new(@viewport)
      # Lieu
      @pokemon_zone = DexWinMap.new(@viewport)
      @state = page_id ? 1 : 0
      @page_id = page_id
      generate_selected_pokemon_array(page_id)
      generate_pokemon_object
      change_state(@state)
      Mouse.wheel = 0
      @pages_index = 0
      @greenscreen = Sprite.new(@viewport)
        .set_bitmap("WinSprite", :pokedex)
        .set_position(6, 16)
      @pages = Sprite.new(@viewport)
        .set_bitmap("pages", :pokedex)
        .set_position(6, 156)
      @pages.src_rect.set(0,0,32,18)
      @pages.visible = false
    end
    
    # Update the interface
    def update
      return unless super
      #update_mouse_ctrl
      return action_A if Input.trigger?(:A)
      return action_X if Input.trigger?(:X)
      return action_Y if Input.trigger?(:Y)
      return action_B if Input.trigger?(:B)
      return action_LEFT if Input.trigger?(:LEFT)
      return action_RIGHT if Input.trigger?(:RIGHT)
      if @state == 0
        max_index = @selected_pokemons.size - 1
        if index_changed(:@index, :UP, :DOWN, max_index)
          update_index
        elsif index_changed!(:@index, :LEFT, :RIGHT, max_index)
          9.times { index_changed!(:@index, :LEFT, :RIGHT, max_index) }
          update_index
        elsif Mouse.wheel != 0
          @index = (@index - Mouse.wheel) % (max_index + 1)
          Mouse.wheel = 0
          update_index
        end
      end
      if(@state == 1)
        @descr_viewport.oy = 96*@pages_index
        @pages.src_rect.set(0+32*@pages_index,0,32,18)
        @pages.visible = true
      else
        @pages.visible = false
      end
      if(@state == 0)
        @greenscreen.opacity = 170
      else
        @upbar.opacity = 0
        @greenscreen.opacity = 0
      end
      @pages_index = 0 if(@state != 1)
      @background.set_bitmap(Background[@state], :pokedex)
    end
    
    # Update the index when changed
    def update_index
      @pokemon.id = @selected_pokemons[@index]
      @pokeface.data = @pokemon
      update_list(true)
    end
    
    # Action triggered when A is pressed
    def action_A
      return $game_system.se_play($data_system.buzzer_se) if @page_id
      $game_system.se_play($data_system.decision_se)
      change_state(@state + 1) if @state < 2
    end
    
    # Action triggered when B is pressed
    def action_B
      $game_system.se_play($data_system.decision_se)
      return @running = false if @state == 0 or @page_id
      change_state(@state - 1) if @state > 0
    end
    
    # Action triggered when X is pressed
    def action_X
      return if @state > 1 
      return $game_system.se_play($data_system.buzzer_se) if @page_id
      return $game_system.se_play($data_system.buzzer_se) #Non programmé
    end
    
    # Action triggered when Y is pressed
    def action_Y
      return if @state > 1
      return $game_system.se_play($data_system.buzzer_se) if @state == 0
      $game_system.cry_play(@pokemon.id) if @state == 1
    end
    
    def action_LEFT
      if(@state == 1)
        @nb_pages = (@pokemon_descr.text.count("\n") / 3.0).ceil
        if(@pages_index != 0)
          @pages_index -= 1
        end
      end
    end
    
    def action_RIGHT
      if(@state == 1)
        @nb_pages = (@pokemon_descr.text.count("\n") / 3.0).ceil
        if(@pages_index != @nb_pages-1)
          @pages_index += 1
        end
      end
    end
    # Array of actions to do according to the pressed button
    Actions = [:action_A, :action_X, :action_Y, :action_B]
    # Update the mouse interaction with the ctrl buttons
    def update_mouse_ctrl
      if Mouse.trigger?(:left)
        @ctrl.each do |sp|
          sp.set_press(sp.simple_mouse_in?)
        end
      elsif Mouse.released?(:left)
        @ctrl.each_with_index do |sp, i|
          if sp.simple_mouse_in?
            send(Actions[i])
          end
          sp.set_press(false)
        end
      end
    end
    
    # Change the state of the Interface
    # @param state [Integer] the id of the state
    def change_state(state)
      @state = state
      @pokeface.data = @pokemon if(@pokeface.visible = state != 2)
      @arrow.visible = @seen_got.visible = state == 0
      @pokemon_info.visible = @pokemon_descr.visible = state == 1
      if @pokemon_descr.visible
        @pokemon_descr.multiline_text = ::GameData::Pokemon.descr(@pokemon.id)
        @pokemon_info.data = @pokemon
      end
      @pokemon_zone.data = @pokemon if(@pokemon_zone.visible = state == 2)
      update_list(state == 0)
    end
    
    # Update the button list
    # @param visible [Boolean]
    def update_list(visible)
      base_index = calc_base_index
      @list.each_with_index do |el, i|
        next unless el.visible = visible
        pos = base_index + i
        id = @selected_pokemons[pos]
        next(el.visible = false) unless id and pos >= 0
        if el.selected = (pos == @index)
          @arrow.y = el.y - 50
        end
        @pokemonlist.id = id
        el.data = @pokemonlist
      end
    end
    
    # Calculate the base index of the list
    # @return [Integer]
    def calc_base_index
      return -1 if @selected_pokemons.size < 7
      if @index >= 7
        return @index - 7
      elsif @index < 7
        return -1
      end
    end
    
    # Generate the selected_pokemon array
    # @param page_id [Integer, false] see initialize
    def generate_selected_pokemon_array(page_id)
      if $pokedex.national?
        1.step($game_data_pokemon.size-1) do |i|
          @selected_pokemons << i if $pokedex.has_seen?(i)
        end
      else
        selected_pokemons = Array.new
        1.step($game_data_pokemon.size-1) do |i|
          selected_pokemons << i if $pokedex.has_seen?(i) and ::GameData::Pokemon.id_bis(i) > 0
        end
        selected_pokemons.sort! { |a, b| ::GameData::Pokemon.id_bis(a) <=> ::GameData::Pokemon.id_bis(b) }
        @selected_pokemons = selected_pokemons
      end
      @selected_pokemons << 0 if @selected_pokemons.size == 0
      # Index ajustment
      if(page_id)
        @index = @selected_pokemons.index(page_id)
        unless @index
          @selected_pokemons << page_id
          @index = @selected_pokemons.size - 1
        end
        #@index -= 1
      else
        @index = 0
      end
    end
    
    # Generate the Pokemon Object
    def generate_pokemon_object
      @pokemon = PFM::Pokemon.new(@selected_pokemons[@index].to_i,1)
      # Return the formated name for Pokedex
      # @return [String]
      def @pokemon.pokedex_name
        sprintf(GamePlay::Dex::NameStr, $pokedex.national? ? self.id : ::GameData::Pokemon.id_bis(self.id), self.name)
      end
      # Return the formated Specie for Pokedex
      # @return [String]
      def @pokemon.pokedex_species
        ::GameData::Pokemon.species(self.id)
      end
      # Return the formated weight for Pokedex
      # @return [String]
      def @pokemon.pokedex_weight
        sprintf(GamePlay::Dex::WeightStr, self.weight)
      end
      # Return the formated height for Pokedex
      # @return [String]
      def @pokemon.pokedex_height
        sprintf(GamePlay::Dex::HeightStr, self.height)
      end
    end
    
    # Dispose the interface
    def dispose
      super
      @viewport.dispose
    end
  end
end