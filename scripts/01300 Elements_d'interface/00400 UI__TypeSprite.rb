module UI
  # Sprite that show the 1st type of the Pokemon
  class Type1Sprite < SpriteSheet
    def initialize(viewport, from_pokedex = false,from_sumary_c = false)
      super(viewport, 1, $game_data_types.size)
      if from_pokedex
        set_bitmap("types", :pokedex)
      elsif from_sumary_c
        set_bitmap("types2", :interface)
      else
        set_bitmap("types", :interface)
      end
    end
  end
end