module UI
  # Dex sprite that show the Pokemon location
  class DexWinMap < SpriteStack
    # Create a new dex win sprite
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :pokedex)
      push(0, 32, "world_map")
      add_text(0, 0, 320, 16, "NID DU POKEMON", 1, color: 3)
    end
    # Change the data
    def data=(pokemon)
      super(pokemon)
      # update the map info with the pokemon X 49 ; Y 38
    end
  end
end