module UI
  # Dex sprite that show the Pokemon infos
  class DexButton < SpriteStack
    # Create a new dex button
    # @param viewport [LiteRGSS::Viewport]
    # @param i [Integer] index of the sprite in the viewport
    def initialize(viewport, i)
      super(viewport, 0, 0, default_cache: :pokedex)
      @catch = push(118, 34, "Catch") #> Should always be the second
      add_text(118, 18, 116, 16, :id_text3, type: SymText, color: 3)
      add_text(134, 34, 116, 16, :name_upper, type: SymText, color: 3)
      @x = 147
      @y = 62
      self.set_position(i == 0 ? 147 : 163, @y - 32 + i * 32)
    end
    # Change the data
    def data=(pokemon)
      super(pokemon)
      @stack[0].visible = ($pokedex.has_captured?(pokemon.id))
    end
    # Set the button in selected state or not
    def selected=(value)
      @stack.last.visible = !value
    end
  end
end