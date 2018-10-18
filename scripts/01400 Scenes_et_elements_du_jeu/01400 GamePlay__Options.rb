module GamePlay
  class Config < Base
    Background = ["Options_Background_1",
    "Options_Background_2",
    "Options_Background_3",
    "Options_Background_4",
    "Options_Background_5",
    "Options_Background_6",
    "Options_Background_7",
    "Options_Background_8"]
    Selector = "cursor_black"
    Skin = ["M_1","M_2","M_3","M_4","M_5","M_6","M_7","M_8"]
    include UI
    include Text::Util
    attr_accessor :text_name
    def initialize
      super
      @viewport = Viewport.create(:main, 1000)
      init_text(0, @viewport)
      #-_-_-_-_-# Variables Globale #-_-_-_-_-#
      # Les variables ci-dessous ne doivent pas
      #  être changé sauf si vous êtes sûr de
      #          ce que vous faites ! 
      #-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-#
      @index = 0                              #=> Index des options
      @switch = 0                             #=> Touche gauche droite pour l'update
      #-_-_-_-_-# Background #-_-_-_-_-#
      @bg = Sprite.new(@viewport)
      @bg.bitmap=RPG::Cache.interface(Background[$game_variables[108]])
      @selector = Sprite.new(@viewport)
      @selector.bitmap=RPG::Cache.interface(Selector)
      @selector.set_position(18,32)
      #-_-_-_-_-# TABLEAUX #-_-_-_-_-#
      #   A partir de ce niveau, les
      # tableaux peuvent être modifiés
      #  pour modifié les options
      #-_-_-_-_-# TABLEAUX #-_-_-_-_-#
      # Les variables sers de stockage pour la sauvegarde en jeu. Pour possiblement
      # mettre a jour par la suite si une autre technique est utilisé.
      # /!\ 7 Maximum ou les options dépasseons de l'ecran /!\
      # Si vous souhaitez ajouté le 7eme Options il faut aussi enlevé les "#" devant 
      # les options correspondante dans les def "draw_options" et "draw_dispose" ( Ce sont les 2 juste en dessous )
      #-_-_-_-_-# CUSTOM #-_-_-_-_-#
      #> Nom et variable des options.
      # NOM | VARIABLE
      @name_options = [
      ["VIT.TEXTE",$game_variables[104]],
      ["ANIMATION COMBAT",$game_variables[105]],
      ["STYLE COMBAT",$game_variables[106]],
      ["MUSIQUE",$game_variables[107]],
      ["EFFETS",$game_variables[108]],
      #> Les fenetre ne fonctionne actuellement que pour le menu des options
      ["FENETRE-BETA",$game_variables[109]]
      ]
      #> Le nom des valeurs ( Ici purement visuel pour affiché au joueur un texte en fonction de l'option )
      # VALEUR 1 | VALEUR 2 | VALEUR 3 | ETC...
      @name_values = [
      ["1","2","3"],
      ["OUI","NON"],
      ["CHOIX","DEFINI"],
      ["0%","25%","50%","75%","100%"],
      ["0%","25%","50%","75%","100%"],
      ["TYPE 1","TYPE 2","TYPE 3","TYPE 4","TYPE 5","TYPE 6","TYPE 7","TYPE 8"]
      ]
      #> Les vrais valeurs. Ici elle servent a modifier l'option réellement.
      # VALEUR 1 | VALEUR 2 | VALEUR 3 | ETC...
      @options_functions = [
      [1,2,3],
      [true,false],
      [true,false],
      [0,25,50,75,100],
      [0,25,50,75,100],
      [1,2,3,4,5,6,7,8]
      ]
      #-_-_-_-_-# FIN DU CUSTOM #-_-_-_-_-#
      #> Retour
      @back = add_text(32, 28+32*7, 120, 23, "RETOUR")
      #> Dessins des options
      draw_options
      options_update
    end
      
    def draw_options
      #-_-_-_-_-# Textes #-_-_-_-_-#
      #> Noms
      @name_options.size.times do |i|
        @text_options = add_text(32, 28+32*i, 120, 23, @name_options[i][0])
      end
      #> Valeurs
      @text_values_0 = add_text(180, 44+32*0, 120, 23, ": "+@name_values[0][$game_variables[104]])
      @text_values_1 = add_text(180, 44+32*1, 120, 23, ": "+@name_values[1][$game_variables[105]])
      @text_values_2 = add_text(180, 44+32*2, 120, 23, ": "+@name_values[2][$game_variables[106]])
      @text_values_3 = add_text(180, 44+32*3, 120, 23, ": "+@name_values[3][$game_variables[107]])
      @text_values_4 = add_text(180, 44+32*4, 120, 23, ": "+@name_values[4][$game_variables[108]])
      @text_values_5 = add_text(180, 44+32*5, 120, 23, ": "+@name_values[5][$game_variables[109]])
      #@text_values_6 = add_text(180, 44+32*6, 120, 23, ": "+@name_values[0][$game_variables[110]])
      #> Background
      @bg.bitmap=RPG::Cache.interface(Background[$game_variables[109]])
      windowskin_name = Skin[1]
    end
    
    #> Sers aux rafraichissement des options
    def draw_dispose
      @text_values_0.dispose
      @text_values_1.dispose
      @text_values_2.dispose
      @text_values_3.dispose
      @text_values_4.dispose
      @text_values_5.dispose
      #@text_values_6.dispose
    end
    
    #> Sers a update la valeurs visuel des options. ( Sers aussi pour la partie non visuel )
    def options_update
      #> Changement de la valeurs en fonction de la touche Gauche/Droite grace a "def update"
      @name_options.size.times do |i|
        if(@index == i)
          if($game_variables[104+i] != 0 and @switch == 1)
            $game_variables[104+i] -= 1
          elsif($game_variables[104+i] != @options_functions[i].size-1 and @switch == 2)
            $game_variables[104+i] += 1
          end
        end
      end
      #> Vitesse des messages
      $options.set_message_speed(@options_functions[0][$game_variables[104]])
      #> Animation en combat
      $options.set_show_animation(@options_functions[1][$game_variables[105]])
      #> Choix ou Défini
      $options.set_battle_mode(@options_functions[2][$game_variables[106]])
      #> Volume de la musique
      Audio.music_volume=(@options_functions[3][$game_variables[107]])
      #> Volume des effets
      Audio.sfx_volume=(@options_functions[4][$game_variables[108]])
      #> Annule/Reprend la musique pour mettre a jour le volume
      $game_system.bgm_memorize
      $game_system.bgm_restore
      #> Fait disparaitre/apparaitre les texte pour mettre a jours
      draw_dispose
      draw_options
    end
    
    #> A ne pas touché sans s'y connaitre ( Sers aux changement d'index avec les touche HAUT/BAS/GAUCHE/DROITE )
    def update
      @selector.y = 32+32*@index
      @selector.y = 256 if(@index == @name_options.size)
      #> HAUT
      if(Input.repeat?(:UP))
        @index -= 1
        @index = @name_options.size if(@index < 0)
      #> BAS
      elsif(Input.repeat?(:DOWN))
        @index += 1
        @index = 0 if(@index > @name_options.size)
      elsif(Input.repeat?(:LEFT))
        @switch = 1
        options_update
      elsif(Input.repeat?(:RIGHT))
        @switch = 2
        options_update
      elsif(Input.repeat?(:B))
        @running = false
      elsif(Input.repeat?(:A) and @index == 6)
        @running = false
      end
    end
    
    def dispose
      super
      @viewport.dispose
    end
    
  end
end