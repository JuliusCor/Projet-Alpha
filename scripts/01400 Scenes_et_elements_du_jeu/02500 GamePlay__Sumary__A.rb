module GamePlay
  class Sumary
    # Show the Informations of the Pokémon in the Sumary interface
    class A < UI::SpriteStack
      Phrases = ["EggPhrase_3","EggPhrase_2","EggPhrase_1"]
      include UI
      def initialize(viewport, x = 0, y = 0, default_cache: :interface)
        super
        texts = _get_file(27)
        @Num = 2
        #|--------------- OEUF ---------------|#
        @egg_phrases = Sprite.new(@viewport)
        #|---------- PARTIE BLANCHE ----------|#
        nompoke = add_text(130, 29, 66, 19, :given_name_upper, type: SymText, color: 0)
        add_text(158, 57, 68, 16, :name_upper, 0, type: SymText)
        add_text(163, 0, 68, 16, :id_text, 0, type: SymText)
        add_text(247, -2, 66, 19, :level_text, type: SymText)
        push(296, 2, nil, type: GenderSprite)
        #|---------- PARTIE COULEUR ----------|#
        #_HP_#
        @hp_bar = push_sprite Bar.new(viewport, 0, 146, 
          RPG::Cache.interface("Menu_pokemon_hp_summary"), 96, 4, 32, 4, 6)
        add_text(50, 160, 50, 16, :hp_text,1, type: SymText)
        #_Statut_#
        add_text(0, 192, 66, 16, "STATUT/")
        add_text(96, 208, 66, 16, "OK")
        push(94, 208, nil, type: StatusSpriteSummary)
        #_Types_#
        add_text(0, 234, 66, 16, "TYPE/")
        push(47, 252, nil, type: Type1Sprite)
        push(47, 252+20, nil, type: Type2Sprite)
        #_XP_#
        add_text(159, 144, 68, 16, "PTS    EXP.")
        add_text(248, 160, 68, 16, :exp_text, 2, type: SymText)
        #_XP_Restant_#
        add_text(159, 192, 68, 16, "PROCH. NIV").set_size(16)
        add_text(248, 208, 68, 16, :exp_remaining_text, 2, type: SymText)
        #_Niv_Suivant_#
        add_text(250, 224, 66, 16, :next_level_string, 2, type: SymText)
        @exp_bar = push_sprite Bar.new(viewport, 176, 262, 
          RPG::Cache.interface("summary_exp"),94, 4, 0, 0, 1)
        #|----------      FIN       ----------|#
      end
      # Change the Pokemon shown
      # @param v [PFM::Pokemon]
      def data=(v)
        return self.visible = false unless v
        if v.egg?
          @egg_phrases.visible = true
          update_egg_phrase(v)
          @egg_phrases.bitmap=RPG::Cache.interface(Phrases[@Num])
          @egg_phrases.y = 126
          self.each { |sprite| sprite.visible = false }
        else
          @egg_phrases.visible = false
          self.each { |sprite| sprite.visible = true }
          @hp_bar.rate = v.hp_rate
          @exp_bar.rate = v.exp_rate
          super
        end
      end
      # Update the egg phrase
      # @param pokemon [PFM::Pokemon]
      def update_egg_phrase(pokemon)
        if(pokemon.step_remaining<1280)
          @Num = 0
        elsif(pokemon.step_remaining<2560)
          @Num = 1
        elsif(pokemon.step_remaining<10240)
          @Num = 2
        else
          @Num = 2
        end
      end
      # Change the visibility of the Informations
      # @param v [Boolean]
      def visible=(v)
        super
        @egg_phrases.visible = v
      end
    end
  end
end