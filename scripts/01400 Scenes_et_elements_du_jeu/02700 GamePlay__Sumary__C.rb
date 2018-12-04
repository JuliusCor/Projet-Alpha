module GamePlay
  class Sumary
    # Show the Informations of the Pokémon in the Sumary interface
    class C < UI::SpriteStack
        attr_accessor :pokemon
      def initialize(viewport, x = 0, y = 0, default_cache: :interface)
        super
        texts = _get_file(27)

        #_-_-_-# EN CONSTRUCTION #_-_-_-#
        #PARTIE HAUTE
        @w = 12 * 18
        push(20, 0, "whitebar").src_rect.set(0, 0, 64+@w, 24)
        add_text(56, 8, 66, 19, :given_name_upper, type: SymText, color: 0)
        add_text(232, 8, 66, 19, :level_text, 2, type: SymText)
        #_-_-_-# EN CONSTRUCTION #_-_-_-#
        
        #_Attaque_#
        4.times do |i|
          push_sprite(Skill_C.new(viewport, i))
          push(160, 52+32*i, "PP")
        end
        #_Descriptions_#
        add_text(16, 160, 68, 16, "TYPE/")
        #push(32, 174, nil, type: Type1Sprite)
        #push(147, 129, nil,false,true, type: TypeSprite)
        add_text(192, 178, 68, 16, "FOR/")
        add_text(192, 196, 68, 16, "PRE/")
        #_Stats_#
        @skill_stack = {
          category: CategorySprite.new(viewport).set_position(32, 196),
          power: SymText.new(0, viewport, 260, 176, 42, 16, :power_text, 2),
          accuracy: SymText.new(0, viewport, 260, 194, 42, 16, :accuracy_text, 2),
          descr: SymMultilineText.new(0, viewport, 14, 216, 296, 30, :description),
          type: TypeSprite.new(viewport).set_position(32, 178)
        }
        #|----------      FIN       ----------|#
      end
      # Change the Pokemon shown
      # @param v [PFM::Pokemon]
      def data=(v)
        return self.visible = false unless v
        self.visible = true
        super
=begin
        if(v.level>99)
          push(-500, -500, "level_n")
        elsif(v.level>9)
          push(220, 14, "level_n")
        else(v.level<10)
          push(266, 14, "level_n")
        end
        
        #@namesize = v.given_name.size
        #add_text(100, 50, 68, 16, @namesize).to_s
=end
      end
    end
  end
end