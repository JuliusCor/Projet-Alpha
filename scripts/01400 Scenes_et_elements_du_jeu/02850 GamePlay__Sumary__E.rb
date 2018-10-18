module GamePlay
  class Sumary
    # Show the Rubans of the Pokémon in the Sumary interface
    class E < UI::SpriteStack
      include UI
      def initialize(viewport, x = 0, y = 0, default_cache: :interface)
        super
        texts = _get_file(27)
        
        #|---------- PARTIE BLANCHE ----------|#
        nompoke = add_text(130, 29, 66, 19, :given_name_upper, type: SymText)
        add_text(158, 57, 68, 16, :name_upper, 0, type: SymText)
        add_text(163, 0, 68, 16, :id_text, 0, type: SymText)
        add_text(247, -2, 66, 19, :level_text, type: SymText)
        push(296, 2, nil, type: GenderSprite)
        #|---------- PARTIE COULEUR ----------|#
        #_Trainer_#
        add_text(0, 128, 68, 16, "DO/")
        add_text(32, 146, 68, 16, :trainer_name_upper, type: SymText)
        push(200, 132, "no_id")
        add_text(250, 147, 68, 13,  :trainer_id_text , 2, type: SymText)
        #_Zone_#
        add_text(0, 212, 100, 16, "ORIGINE/")
        add_text(32, 231, 288, 16, :captured_zone_name, type: SymMultilineText)
        #_Nature_#
        add_text(0, 254, 132, 16, "NATURE/")
        add_text(32, 273, 132, 16, :nature_text_upper, type: SymText)
        #_Rencontre_#
        add_text(0, 170, 132, 16, "RENCONTRE/")
        push(32, 191, "team/level_n")
        @pokemon_phrase = add_text(46, 187, 600, 16, nil.to_s)
        #|----------      FIN       ----------|#
      end
      # Update the Pokemon phrase
      # @param pokemon [PFM::Pokemon]
      def update_pokemon_phrase(pokemon)
        time = Time.new
        time -= (time.to_i-1)
        time += pokemon.captured_at
        @pokemon_phrase.multiline_text = _parse(28,25, "[VAR NUM3(0003)]" => pokemon.captured_level.to_s,
        "[VAR NUM2(0002)]" => time.strftime("%d"),
        "[VAR NUM2(0001)]" => time.strftime("%m"),
        "[VAR NUM2(0000)]" => time.strftime("%y"),
        "[VAR LOCATION(0004)]" => pokemon.captured_zone_name)
      end
      # Change the Pokemon shown
      # @param v [PFM::Pokemon]
      def data=(v)
        return self.visible = false unless v
        self.visible = true
        update_pokemon_phrase(v)
        super
      end
    end
  end
end