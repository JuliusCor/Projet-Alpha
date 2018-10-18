module GamePlay
  # Class that display the Party Menu interface and manage user inputs
  #
  # This class has several modes
  #   - :map => Used to select a Pokemon in order to perform stuff
  #   - :menu => The normal mode when opening this interface from the menu
  #   - :battle => Select a Pokemon to send to battle
  #   - :item => Select a Pokemon in order to use an item on it (require extend data : hash)
  #   - :hold => Give an item to the Pokemon (requires extend data : item_id)
  #
  # This class can also show an other party than the player party,
  # the party paramter is an array of Pokemon upto 6 Pokemon
  class Party_Menu < Base
    # Return data of the Party Menu
    # @return [Integer]
    attr_accessor :return_data
    # Return the skill process to call
    # @return [Array(Proc, PFM::Pokemon, PFM::Skill), Proc, nil]
    attr_accessor :call_skill_process
    # Selector Rect info
    # @return [Array]
    SelectorRect = [0, 0, 132, 52]
    # Create a new Party_Menu
    # @param party [Array<PFM::Pokemon>] list of Pokémon in the party
    # @param mode [Symbol] :map => from map (select), :menu => from menu, :battle => from Battle, :item => Use an item, :hold => Hold an item, :choice => processing a choice related proc (do not use)
    # @param extend_data [Integer, Hash] extend_data informations
    # @param no_leave [Boolean] tells the interface to disallow leaving without choosing
    def initialize(party, mode = :map, extend_data = nil, no_leave: false)
      super()
      @move = -1
      @return_data = -1
      # Scene mode
      # @type [Symbol]
      @mode = mode
      # Displayed party
      # @type [Integer, Hash, nil]
      @extend_data = extend_data
      @no_leave = no_leave
      @index = 0
      # @type [Array<PFM::Pokemon>]
      @party = party
      @counter = 0 #  Used by the selector
      @intern_mode = :normal # :normal, :move_pokemon, :move_item, :choose_move_pokemon, :choose_move_item
      # Scene viewport
      # @type [LiteRGSS::Viewport]
      @viewport = Viewport.create(:main, 10_000)
      create_background
      create_team_buttons
      create_selector
      create_win_text
      create_retour
      init_win_text
      # Telling the B action the user is seeing a choice and make it able to cancel the choice
      # @type [PFM::Choice_Helper]
      @choice_object = nil
      # Running state of the scene
      # @type [Boolean]
      @running = true
    end
    
    def create_retour
      @retour = Sprite.new(@viewport).set_bitmap('team/retour', :interface)
      @retour.x = 16
      @retour.y = 208
    end
    
    # Create the background sprite
    def create_background
      # Scene background
      # @type [LiteRGSS::Sprite]
      @background = Sprite.new(@viewport).set_bitmap('team/Menu_pokemon_background', :interface)
    end

    # Create the team buttons
    def create_team_buttons
      @team_buttons = Array.new(@party.size) do |i|
        btn = UI::TeamButton.new(@viewport, i)
        btn.data = @party[i]
        next(btn)
      end
    end

    # Creation du Curseur
    def create_selector
      @selector = Sprite.new(@viewport).set_bitmap('team/cursor', :interface)
      @selector.src_rect.set(0,0,10,14)
      @selector2 = Sprite.new(@viewport).set_bitmap('team/cursor', :interface)
      @selector2.visible = false
      update_selector_coordinates
    end
    
    # Create the text window (info to the player)
    def create_win_text
      # Scene Text window (info)
      # @type [UI::SpriteStack]
      @winText = UI::SpriteStack.new(@viewport)
      @winText.push(0, 217, 'team/Win_Txt')
      # Real text info
      # @type [LiteRGSS::Text]
      @text_info = @winText.add_text(2, 2, 238, 15, nil.to_s, color: 9)
      @text_info.opacity = 0
      @winText.opacity = 0
    end
    
    # Initialize the win_text according to the mode
    def init_win_text
      case @mode
      when :map, :battle
        return @text_info.text = _get(23, 17)
      when :hold
        return @text_info.text = _get(23, 23)
      when :item
        if @extend_data
          extend_data_button_update
          return @text_info.text = _get(23, 24)
        end
      end
    end

    # Function that update the team button when extend_data is correct
    def extend_data_button_update
      if (_proc = @extend_data[:on_pokemon_choice])
        apt_detect = (@extend_data[:open_skill_learn] or @extend_data[:stone_evolve])
        @team_buttons.each do |btn|
          btn.show_item_name
          v = @extend_data[:on_pokemon_choice].call(btn.data)
          if apt_detect
            c = (v ? 1 : v == false ? 2 : 3)
            v = (v ? 143 : v == false ? 144 : 142)
          else
            c = (v ? 1 : 2)
            v = (v ? 140 : 141)
          end
          btn.item_text.load_color(c).text = _parse(22, v)
        end
      end
    end

    # Globaly update the scene
    def update
      update_during_process
      return unless super
      return action_B if(Input.trigger?(:A) and @index == 6)
      return action_A if(Input.trigger?(:A) and @index != 6)
      return action_B if Input.trigger?(:B)
      update_selector_move
    end

    def update_selector
    end
    
    def update_background_animation
    end
    
    # Update the scene during an animation or something else
    def update_during_process
      update_selector
      update_background_animation
      update_team_buttons
    end
    
    def update_team_buttons
      @team_buttons.each { |button| button.update if button }
    end

    # Show the winText
    # @param str [String] String to put in the Win Text
    def show_winText(str)
    end

    # Hide the winText
    def hide_winText
      selector_black
      selector2_del if(@selector2.visible = true)
    end
    
    # Show the item name
    def show_item_name
      @team_buttons.each(&:show_item_name)
    end

    # Hide the item name
    def hide_item_name
      @team_buttons.each(&:hide_item_name)
    end

    def dispose
      super
      @viewport.dispose
    end
  end
end