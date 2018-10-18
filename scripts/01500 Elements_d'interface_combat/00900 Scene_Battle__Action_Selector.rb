class Scene_Battle
  # Action Selector interface
  #
  # This interface is used during battle and allows the user to choose an action on a specific Pokemon
  class Action_Selector < UI::SpriteStack
    Bar="Choice_4"
    Selector="Choice_Select"
    # Creates a new Action Selector interface
    def initialize
      super(nil)
      push(0, 0, "choice_4").z = 10005
      @select_sprite = push(0, 0, "cursor_black")
      @select_sprite.z = z = 10006
      #-_-_-_-_-# PATTERN #-_-_-_-_-#
      #      ATTAQUE | PKM
      #          SAC | FUITE
      #-_-_-_-_-# PATTERN #-_-_-_-_-#
      @textx = 128
      @texty = 224
      add_text(@textx,    @texty,    100, 16, _get(32,0), 0, color: 0).set_size(16).z = z #ATTAQUE
      push(    @textx+96, @texty,    "pkmn")                                       .z = z #POKEMON
      add_text(@textx,    @texty+32, 100, 16, _get(32,1), 0, color: 0).set_size(16).z = z #SAC
      add_text(@textx+96, @texty+32, 100, 16, _get(32,3), 0, color: 0).set_size(16).z = z #FUITE
      self.visible = false
      self.pos_selector(0)
    end
    # Sets the position of the selector
    # @param action_index [Integer] the index of the action (0 to 3)
    def pos_selector(action_index)
      sprite = @select_sprite
      sprite.angle = 0
      sprite.ox = sprite.oy = 0
      sprite.mirror = false
      case action_index
      when 0 #> Attaquer
        sprite.x = 114
        sprite.y = 224
      when 1 #> Pokémon
        sprite.x = 114 + 96
        sprite.y = 224
      when 2 #> Sac
        sprite.x = 114
        sprite.y = 224 + 32
      else #> Fuite
        sprite.x = 114 + 96
        sprite.y = 224 + 32
      end
    end
    # Sets the Pokemon used to show the Action Selector
    alias pokemon= data=
    # Ranges that describe the Attack button surface
    ATK = [0..0, 0..0]
    # Ranges that describe the Pokemon button surface
    POK = [0..0, 0..0]
    # Ranges that describe the Bag button surface
    BAG = [0..0, 0..0]
    # Ranges that describe the Flee button surface
    RUN = [0..0, 0..0]
    # Action to do when mouse clicks on the interface
    # @param index [Integer] the index of the current action
    # @return [Array(Symbol, Integer)] forced_action, new_index
    # @note forced_action return can be nil
    def mouse_action(index)
      mx, my = @stack[0].translate_mouse_coords
      return :A, 0 if ATK[0].include?(mx) and ATK[1].include?(my)
      return :A, 1 if POK[0].include?(mx) and POK[1].include?(my)
      return :A, 2 if BAG[0].include?(mx) and BAG[1].include?(my)
      return :A, 3 if RUN[0].include?(mx) and RUN[1].include?(my)
      return nil, index
    end
  end
end