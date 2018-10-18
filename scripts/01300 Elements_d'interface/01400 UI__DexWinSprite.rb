module UI
  # Dex sprite that show the Pokemon sprite with its name
  class DexWinSprite < SpriteStack
    # Create a new dex win sprite
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :pokedex)
      #push(6, 16, "WinSprite")
      push(62, 128, nil, type: PokemonFaceSprite)
      #push(6, 16, "WinSprite").opacity = 170
    end
  end
end