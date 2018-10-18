module GamePlay
  class Sumary
    # Show the Rubans of the Pokémon in the Sumary interface
    class D < UI::SpriteStack
      StatsSprite = "Name_Stats"
      include UI
      def initialize(viewport, x = 0, y = 0, default_cache: :interface)
        super
        texts = _get_file(27)
        
        #|---------- PARTIE BLANCHE ----------|#
        nompoke = add_text(130, 29, 66, 19, :given_name_upper, type: SymText, color: 0)
        add_text(158, 57, 68, 16, :name_upper, 0, type: SymText)
        add_text(163, 0, 68, 16, :id_text, 0, type: SymText)
        add_text(247, -2, 66, 19, :level_text, type: SymText)
        push(296, 2, nil, type: GenderSprite)
        #|---------- PARTIE COULEUR ----------|#
        @lineh = 22
        @line_y = 163
        @line_x = 124
        # | STATS | #
        add_text(0, 130, 50, 13, "STATS/")
        add_text(180, 130, 50, 13, "IV/")
        add_text(250, 130, 50, 13, "EV/")
        # - Name Stats -
        @stats_hp =     push(0, @line_y+@lineh*0, StatsSprite) # HP
        @stats_hp.src_rect.set(0,14*0,111,14)
        @stats_atq =    push(0, @line_y+@lineh*1, StatsSprite) # Attaque
        @stats_atq.src_rect.set(0,14*1,111,14)
        @stats_def =    push(0, @line_y+@lineh*2, StatsSprite) # Défense
        @stats_def.src_rect.set(0,14*2,111,14)
        @stats_atqspe = push(0, @line_y+@lineh*3, StatsSprite) # Vitesse
        @stats_atqspe.src_rect.set(0,14*3,111,14)
        @stats_defspe = push(0, @line_y+@lineh*4, StatsSprite) # Atq.Spé
        @stats_defspe.src_rect.set(0,14*4,111,14)
        @stats_vit =    push(0, @line_y+@lineh*5, StatsSprite) # Déf.Spé
        @stats_vit.src_rect.set(0,14*5,111,14)
        
        # - Stats -
        add_text(@line_x, @line_y          , 50, 13, :hp       , 2, type: SymText) # HP
        add_text(@line_x, @line_y+@lineh*1 , 50, 13, :atk_basis, 2, type: SymText) # Attaque
        add_text(@line_x, @line_y+@lineh*2 , 50, 13, :dfe_basis, 2, type: SymText) # Défense
        add_text(@line_x, @line_y+@lineh*3 , 50, 13, :spd_basis, 2, type: SymText) # Vitesse
        add_text(@line_x, @line_y+@lineh*4 , 50, 13, :ats_basis, 2, type: SymText) # Atq.Spé
        add_text(@line_x, @line_y+@lineh*5 , 50, 13, :dfs_basis, 2, type: SymText) # Déf.Spé
        # | AJOUT EV/IV | #
        # - IV -
        add_text(@line_x+70, @line_y          , 50, 13, :iv_hp , 2, type: SymText) # HP
        add_text(@line_x+70, @line_y+@lineh*1 , 50, 13, :iv_atk, 2, type: SymText) # Attaque
        add_text(@line_x+70, @line_y+@lineh*2 , 50, 13, :iv_dfe, 2, type: SymText) # Défense
        add_text(@line_x+70, @line_y+@lineh*3 , 50, 13, :iv_spd, 2, type: SymText) # Vitesse
        add_text(@line_x+70, @line_y+@lineh*4 , 50, 13, :iv_ats, 2, type: SymText) # Atq.Spé
        add_text(@line_x+70, @line_y+@lineh*5 , 50, 13, :iv_dfs, 2, type: SymText) # Déf.Spé
        # - EV -
        add_text(@line_x+142, @line_y          , 50, 13, :ev_hp , 2, type: SymText) # HP
        add_text(@line_x+142, @line_y+@lineh*1 , 50, 13, :ev_atk, 2, type: SymText) # Attaque
        add_text(@line_x+142, @line_y+@lineh*2 , 50, 13, :ev_dfe, 2, type: SymText) # Défense
        add_text(@line_x+142, @line_y+@lineh*3 , 50, 13, :ev_spd, 2, type: SymText) # Vitesse
        add_text(@line_x+142, @line_y+@lineh*4 , 50, 13, :ev_ats, 2, type: SymText) # Atq.Spé
        add_text(@line_x+142, @line_y+@lineh*5 , 50, 13, :ev_dfs, 2, type: SymText) # Déf.Spé
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