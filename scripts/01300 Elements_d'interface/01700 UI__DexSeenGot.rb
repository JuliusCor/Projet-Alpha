module UI
  # Dex sprite that show the Pokemon location
  class DexSeenGot < SpriteStack
    # Create a new dex win sprite
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :pokedex)
      add_text(102, 187, 79, 26, :pokemon_seen, type: SymText, color: 3)
      add_text(102, 235, 79, 26, :pokemon_captured, type: SymText, color: 3)
      self.data = $pokedex
    end
  end
end