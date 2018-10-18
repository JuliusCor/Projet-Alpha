module UI
  # Class that show the icon sprite of a Pokemon
  class PokemonFootSprite2 < Sprite::WithColor
    WhiteColor = [1, 1, 1, 1]
    # Format of the icon name
    D3 = '%03d'
    # Set the pokemon
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if(self.visible = (pokemon ? true : false))
        self.bitmap = RPG::Cache.foot_print(sprintf(D3,pokemon.id))
        self.set_color(WhiteColor)
      end
    end
  end
end