module UI
  # Dex sprite that show the Pokemon infos
  class DexWinInfo < SpriteStack
    # Create a new dex win sprite
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :pokedex)
      @foot = push(278, 16, nil, type: PokemonFootSprite2)
      @foot.zoom = 2
      add_text(54, 128, 116, 16, :id_text3, type: SymText, color: 3)
      add_text(134, 48, 116, 16, :name_upper, type: SymText, color: 3)
      add_text(134, 78, 116, 16, :pokedex_species, type: SymText, color: 3)
      add_text(144, 112, 116, 16, :height, 2, type: SymText, color: 3)
      add_text(144, 144, 116, 16, :weight, 2, type: SymText, color: 3)
    end
    # Change the data
    def data=(pokemon)
      super(pokemon)
      @stack[2].text = "???m" if(!$pokedex.has_captured?(pokemon.id))
      @stack[3].text = "???kg" if(!$pokedex.has_captured?(pokemon.id))
    end
  end
end