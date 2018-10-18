module GamePlay
  class Sumary
    # Show the Informations of the Pokémon in the Sumary interface
    class Skill_C < UI::SpriteStack
      include UI
      def initialize(viewport, i, x = 0, y = 0, default_cache: :interface)
        super(viewport, x, y + i * 32, default_cache: default_cache)
        #push(147, 129, nil,false,true, type: TypeSprite)
        add_text(32, 34, 85, 16, :name_upper, type: SymText)
        #add_text(211, 105, 20, 16, _get(27, 32)) # PP
        add_text(184,    50, 52, 16, :pp, 2, type: SymText)
        add_text(184+18, 50, 52, 16, "/", 2)
        add_text(184+50, 50, 52, 16, :ppmax, 2, type: SymText)
        @i = i
      end
      # Change the Pokemon shown
      # @param v [PFM::Pokemon]
      def data=(v)
        return self.visible = false unless v
        v = v.skills_set[@i]
        return self.visible = false unless v
        self.visible = true
        super
      end
    end
  end
end