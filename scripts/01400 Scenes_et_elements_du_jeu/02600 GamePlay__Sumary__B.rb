module GamePlay
  class Sumary
    # Show the Informations of the Pokémon in the Sumary interface
    class B < UI::SpriteStack
      def initialize(viewport, x = 0, y = 0, default_cache: :interface)
        super
        texts = _get_file(27)
        
        #|---------- PARTIE BLANCHE ----------|#
        add_text(130, 29, 66, 19, :given_name_upper, type: SymText, color: 0)
        add_text(158, 57, 68, 16, :name_upper, 0, type: SymText)
        add_text(163, 0, 68, 16, :id_text, 0, type: SymText)
        add_text(247, -2, 66, 19, :level_text, type: SymText)
        push(296, 2, nil, type: GenderSprite)
        #|---------- PARTIE COULEUR ----------|#
        #_Objets_#
        add_text(0, 128, 68, 16, "OBJET/")
        add_text(223, 128, 95, 16, :item_name, 2, type: SymText)
        #_Attaques_#
        add_text(0, 144, 68, 16, "CAPACITE/")
        4.times do |i|
          push_sprite(Skill_B.new(viewport, i))
        end
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