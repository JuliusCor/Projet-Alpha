module UI
  # Dex sprite that show the Pokemon location
  class TrainerGot < SpriteStack
    # Create a new dex win sprite
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :pokedex)
      add_text(0, 0, 79, 26, :pokemon_captured, 2, type: SymText)
      self.data = $pokedex
    end
  end
end