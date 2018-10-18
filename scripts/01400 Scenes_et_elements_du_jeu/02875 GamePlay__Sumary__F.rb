module GamePlay
  class Sumary
    # Show the Rubans of the Pokémon in the Sumary interface
    class F < UI::SpriteStack
      include UI
      def initialize(viewport, x = 0, y = 0, default_cache: :interface)
        super
        texts = _get_file(27)
        #_Talent_#
        add_text(14 , 12,  68, 16,  "TALENT/")
        add_text(14 , 30,  50, 16,  :ability_name_upper, type: SymText)
        #_Description_#
        add_text(14, 54, 296, 26, :ability_descr, 0, type: SymMultilineText)
        #|----------      FIN       ----------|#
      end

      # Change the Pokemon shown
      # @param v [PFM::Pokemon]
      def data=(v)
        return self.visible = false unless v
        self.visible = true
        super
      end
    end
  end
end