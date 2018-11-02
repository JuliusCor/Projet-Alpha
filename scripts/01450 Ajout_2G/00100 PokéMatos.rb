# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Maxoumi
# Merci : SMB64 pour sa grande aide. Nuri Yuri pour PSDK
# Date: 2018
# Description: PoKéMatos
module GamePlay
  class PokeMatos < Base
      Background=["pokematos/Matos1","pokematos/Matos2","pokematos/Matos3","pokematos/Matos4"]
      Icones=["pokematos/Matos_icons1","pokematos/Matos_icons2","pokematos/Matos_icons3","pokematos/Matos_icons4"]
      Icons="pokematos/Matos_icons"
      Jours=["LUNDI","MARDI","MERCREDI","JEUDI","VENDREDI","SAMEDI","DIMANCHE"]
      include UI
      include Text::Util
      attr_accessor :text_name
    #def initialize(mode=:menu)
    def initialize
      super()
      @viewport = Viewport.create(:main, 1000)
      init_text(0, @viewport)
      @mode = $game_switches[152]
      #-_-_-_-_-# Variables Globale #-_-_-_-_-#
      # Les variables ci-dessous ne doivent pas
      #  être changé sauf si vous êtes sûr de
      #          ce que vous faites ! 
      #-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-#
      @width = 288                            #=> Taille en hauteur de l'ecran
      @index = 0                              #=> Index global du PokéMatos
      @tel_index = 0                          #=> Index du téléphone
      @heure = $game_variables[10].to_s       #=> Récupere la variable de l'heure
      @minute = $game_variables[11].to_s      #=> Récupere la variable des minutes
      @dots_counter = 0                       #=> Variable du ":" de l'heure pour le clignotement
      @tel_counter = 0                        #=> Variable du téléphone pour réecrire les texte
      @freq = $game_variables[102]            #=> Numéro de la fréquence de la radio
      @freq_counter = 0                       #=> Compteur de la description de la radio
      @sub_freq_counter = 0                   #=> Sub fréquence
      @music_fade = 0                         #=> Enclenchement Musique Radio
      #@icon_sex = 0                          #=> Variable du sexe pour les icones
      if($trainer.playing_girl)
        @icon_sex = 32
      else
        @icon_sex = 0
      end
      #-_-_-_-_-# Background #-_-_-_-_-#
      @map = Sprite.new(@viewport)
      @map.bitmap=RPG::Cache.interface("pokematos/world_map")
      @map.y = 32
      @bg = Sprite.new(@viewport)
      @bg.bitmap=RPG::Cache.interface(Background[0])
      #-_-_-_-_-# Custom #-_-_-_-_-#
      #   A partir de ce niveau, les
      # variables peuvent être modifiés
      #  pour customiser l'interface.
      #-_-_-_-_-# Icones #-_-_-_-_-#
      #> Var Temps
      @space_icon = 32 #=> Espacement entre les icones du PoKéMatos | DEFAULT = 32
      #> Temps
      @icon1 = Sprite.new(@viewport)
      @icon1.bitmap=RPG::Cache.interface(Icons)
      @icon1.src_rect.set(@icon_sex,0,32,32)
      @icon1.set_position(@space_icon*0,0)
      #> Carte
      @icon2 = Sprite.new(@viewport)
      @icon2.bitmap=RPG::Cache.interface(Icons)
      @icon2.src_rect.set(@icon_sex,32,32,32)
      @icon2.set_position(@space_icon*1,0)
      @icon2.visible = false if(!$game_switches[127])
      #> Telephone
      @icon3 = Sprite.new(@viewport)
      @icon3.bitmap=RPG::Cache.interface(Icons)
      @icon3.src_rect.set(@icon_sex,64,32,32)
      @icon3.set_position(@space_icon*2,0)
      @icon3.visible = false if(!$game_switches[128])
      #> Radio
      @icon4 = Sprite.new(@viewport)
      @icon4.bitmap=RPG::Cache.interface(Icons)
      @icon4.src_rect.set(@icon_sex,96,32,32)
      @icon4.set_position(@space_icon*3,0)
      @icon4.visible = false if(!$game_switches[129])
      #-_-_-_-_-# Sprites #-_-_-_-_-#
      #> Selecteur Global
      @global_selector = Sprite.new(@viewport)
      @global_selector.bitmap=RPG::Cache.interface("pokematos/Matos_cursor")
      @global_selector.set_position(4,26)
      #_____# Telephone #_____#
      #> Selecteur Telephone
      @tel_selector = Sprite.new(@viewport)
      @tel_selector.bitmap=RPG::Cache.interface("cursor")
      @tel_selector.set_position(18,66)
      @tel_selector.src_rect.set(0,0,10,14)
      @tel_selector.visible = false
      #_____# Radio #_____#
      #> Frequence 
      @bar_freq = Sprite.new(@viewport)
      @bar_freq.bitmap=RPG::Cache.interface("pokematos/Matos_freq")
      @bar_freq.visible = false
      @bar_freq.set_position(144,16)
      #-_-_-_-_-# TEXTE #-_-_-_-_-#
      #> Dates
      @jour = add_text(98, 92, 120, 23, Jours[$game_variables[16]], 1)
      #> Heures
      @heures = add_text(32-2, 120, 120, 23, @heure, 2)
      @dots = add_text(42-2, 120, 120, 23, ":", 2)
      @minutes = add_text(78-2, 120, 120, 23, @minute, 2)
      #_____# Telephone #_____#
      #> Var Noms Telephone
      @space_tel = 16  #=> Espace entre chaques nom | DEFAULT = 16
      #> Texte des noms Telephone
      #Nom 1
      @name1  =     add_text(32, 62+@space_tel*0, 120, 23, "")
      @sub_name1  = add_text(80, 62+@space_tel*1, 120, 23, "")
      #Nom 2
      @name2  =     add_text(32, 62+@space_tel*2, 120, 23, "")
      @sub_name2  = add_text(80, 62+@space_tel*3, 120, 23, "")
      #Nom 3
      @name3  =     add_text(32, 62+@space_tel*4, 120, 23, "")
      @sub_name3  = add_text(80, 62+@space_tel*5, 120, 23, "")
      #Nom 4
      @name4  =     add_text(32, 62+@space_tel*6, 120, 23, "")
      @sub_name4  = add_text(80, 62+@space_tel*7, 120, 23, "")
      @name1.visible = @name2.visible = @name3.visible = @name4.visible = false
      @sub_name1.visible = @sub_name2.visible = @sub_name3.visible = @sub_name4.visible = false
	  #-_-# FIN #-_-#
	  #>Nom des numéros et leurs variables
      @text_name = [
      
      #-_-_-_-_-_-_-# CUSTOM TEL #-_-_-_-_-_-_-#
      #     Modifiez le tableau ci-dessous      #
      #    pour personnalisé le telephone.     #
      #-_-_-_-_-_-_-# CUSTOM TEL #-_-_-_-_-_-_-#
      #> Pour personnalisé le texte de l'appel il faut modifié l'evenement commun "51"
      #> ATTENTION ! Fonctionne avec 4 entrées ( Si vous voulez ajouté de nouveaux numéros il faut ajouté 4 entrées )
      #> Vous pouvez en revanche laissé vide pour n'ajouter qu'un seul element. ( Par exemple : Si vous voulez ajouté qu'un numéro vous ajouté 4 enmplacement mais 3 vide )
      #> Veuillez tout de même ne pas mettre d'entrée vide au millieu des autres numéros.
      #> EXEMPLE NORMAL   #> ["VINCENT","ECOLIER",$game_variables[129]]     | RESULTAT #> VINCENT : ECOLIER
      #> EXEMPLE BLOQUER  #> ["NOM","DESCRIPTION",0]                        | RESULTAT #> ------- --------
      #> EXEMPLE VIDE     #> ["","",""]                                     | RESULTAT #>
      # NOM | DESCRIPTION | ACTIVE OU NON ( Fonctionne avec variable : 0 : OFF | 1 : ACTIVE )
      ["MAMAN","",$game_variables[126]],
      ["PROF.CHEN","",$game_variables[127]],
      ["LEO","",$game_variables[128]],
      ["VINCENT","ECOLIER",$game_variables[129]],
      ["RICHARD","MONTAGNARD",$game_variables[130]],
      ["JEAN","TOP DRESSEUR",0],
      ["AURE","FILLETTE",$game_variables[132]],
      ["MICHAEL","POLICIER",$game_variables[133]],
      ["HUMIA","FLEURISTE",$game_variables[134]],
      ["ARNO","SCENTIFIQUE",$game_variables[135]],
      ["","",""],
      ["","",""]
      ]
      #=> Nombres de numéros de Telephone ( Ne pas touché ce calcule automatiquement)
      @name_number = @text_name.size
      #-_-# FIN #-_-#
      
      #_____# Radio #_____#
      #>Texte du nom de la radio
      @text_nom_radio  = add_text(36, 140, 120, 24, "")
      #>Texte de la description de la radio
      @text_descr_radio  = add_text(18, 220, 290, 30, "")
      #>Tableau des radios
      @nom_radio = [
      #-_-_-_-_-_-_-# CUSTOM RADIO #-_-_-_-_-_-_-#
      #      Modifiez le tableau ci-dessous       #
      #       pour personnalisé la radio.        #
      #-_-_-_-_-_-_-# CUSTOM RADIO #-_-_-_-_-_-_-#
      #> Ce tableau défini le nom, l'emplacement et la musique que la radio utilisera.
      # NOM DE LA RADIO | EMPLACEMENT DE LA RADIO SUR LES FREQUENCES | MUSIQUE RADIO
      ["Radio 46",4,"Audio/BGM/2G_Radio_Mot_De_Passe.mp3"],
      ["Musique Pokemon",20,"Audio/BGM/2G_Radio_Marche_Pokemon.mp3"],
      ["Prof. Pokemon",12,"Audio/BGM/2G_Radio_Professeur.mp3"],
      ["Etrange",36,"Audio/BGM/2G_Ruines_Alpha_Short.mp3"]
      ]
      #-_-# FIN #-_-#
      
      #>Tableau des descriptions des radios
      @descr_radio = [
      #-_-_-_-_-_-_-# CUSTOM DESCR RADIO #-_-_-_-_-_-_-#
      #         Modifiez le tableau ci-dessous          #
      #       pour personnalisé la descriptions.       #
      #-_-_-_-_-_-_-# CUSTOM DESCR RADIO #-_-_-_-_-_-_-#
      #> Ce tableau défini les descriptions de la radio.
      # DESCRIPTION DES RADIOS ( Vous pouvez ajouté autant de phrases que vous le souhaitez, le script va les charger dans l'ordre )
      ["Bienvenue a la Radio 46 ! Amusez-vous bien !"],
      ["Vous écoutez actuellement la Radio Musique Pokemon !","Venez nous voir a la tour radio pour faire des échanges Pokemon !"],
      ["Ici le Prof.Pokemon, vous obtiendrez sur cette","radio des infos sur les pokémon sauvages.","Des Spinda on été aperçus sur la route 3","et des Pikachu sur la route 10 !"],
      ["LNK ET KHNMX 13 NG IHDXFHG EXZXGWTBKX","XLM IKXLXGM WTGL NG KXVHBG TN GHKW"]
      ]
      #> Vitesse de défilement des descriptions ( Plus haut c'est. Plus lent sera le défilement )
      @spd_descr = 180
      #-_-# FIN #-_-#
      if($game_switches[152] == true)
      	$game_switches[152] == false
      	@index = 1
      	@bg.bitmap=RPG::Cache.interface(Background[@index])
      end
      draw_scene
      return_map if($game_switches[152] == true)
    end
    
    def return_map
      @index = 1
      $game_switches[149] = false
      @global_selector.set_position(36,26)
    end

    def update
      super
      #Global
      @global_selector.x = 4+@index*32
      #Default
      if(@index == 0)
        @dots_counter +=1
        @dots.visible = false if(@dots_counter == 60)
        if(@dots_counter == 120)
          @dots.visible = true
          @dots_counter = 0
        end
      end
      #Radio
      @bar_freq.x = 144+@freq*4
      if(@index == 3)
        @freq_counter +=1
        if(@freq_counter == @spd_descr)
          @freq_counter = 0
          @sub_freq_counter +=1
          draw_freq
        end
      end
      #>TOUCHE
      if(Input.repeat?(:DOWN))
        if(@index == 2)
          @tel_index += 1 if(@tel_index < @name_number)
          @tel_selector.y += 32 #if(@tel_index < @name_number)
          if(@text_name[@tel_index][2] == "" or @tel_index == @name_number or @tel_counter > @name_number/4)
            @tel_index = 0
            @tel_counter = 0
            @tel_selector.y = 66
            draw_tel
          elsif(@tel_index == 4+4*@tel_counter)
            @tel_counter += 1
            @tel_selector.y = 66
            draw_tel
          end
        end
        if(@index == 3)
          @freq -= 1 if(@freq > 0)
          @freq_counter = 0
          @sub_freq_counter = 0
          @Music = Audio.bgm_fade(180)
          draw_freq
        end
      elsif(Input.repeat?(:UP))
        if(@index == 2)
          @tel_index -= 1
          @tel_selector.y -= 32
          if(@tel_index == 4*@tel_counter-1 and @tel_counter > 0)
            @tel_counter -= 1
            @tel_selector.y = 162
            draw_tel
          elsif(@tel_index < 0)
            @tel_counter = @name_number/4-1
            @tel_index = @name_number-1
            @tel_selector.y = 162
            draw_tel
          end
          3.times do
            if(@text_name[@tel_index][2] == "")
              @tel_index -= 1
              @tel_selector.y -= 32
              draw_tel
            end
          end
        end
        if(@index == 3)
          @freq += 1 if(@freq < 40)
          @freq_counter = 0
          @sub_freq_counter = 0
          @Music = Audio.bgm_fade(180)
          draw_freq
        end
      elsif(Input.repeat?(:LEFT))
        @index -=1
        @index = 3 if(@index<0)
        @index -= 1 if(@icon4.visible == false and @index == 3)
        @index -= 1 if(@icon3.visible == false and @index == 2)
        @index -= 1 if(@icon2.visible == false and @index == 1)
        @bg.bitmap=RPG::Cache.interface(Background[@index])
        $game_system.se_play($data_system.decision_se)
        draw_scene
      elsif(Input.repeat?(:RIGHT))
        @index += 1
        @index += 1 if(@icon2.visible == false and @index == 1)
        @index += 1 if(@icon3.visible == false and @index == 2)
        @index += 1 if(@icon4.visible == false and @index == 3)
        @index = 0 if(@index>3)
        @bg.bitmap=RPG::Cache.interface(Background[@index])
        $game_system.se_play($data_system.decision_se)
        draw_scene
      elsif(trigger?(:B))
        $game_variables[102] = @freq
        @running = false
      elsif(trigger?(:A))
        if(@index == 1)
          @running = false
          $game_switches[152] = true
          call_scene(WorldMap)
        end
        if(@text_name[@tel_index][2] == "")
        elsif(@text_name[@tel_index][2] > 0)
          @running = false if(@index == 0 or @index == 1)
          draw_message if(@index == 2)
        end
      end
    end
    
    #> Dessin des scenes
    def draw_scene
      #_____# GLOBAL #_____#
      @heures.visible = @dots.visible = @minutes.visible = @jour.visible = false
      #_____# Telephone #_____#
      @tel_selector.visible = false
      @name1.visible = @name2.visible = @name3.visible = @name4.visible = false
      @sub_name1.visible = @sub_name2.visible = @sub_name3.visible = @sub_name4.visible = false
      #_____# Radio #_____#
      @bar_freq.visible = false
      @text_descr_radio.visible = @text_nom_radio.visible = false
      #_____# Dessins des scènes #_____#
      draw_def if(@index == 0)
      draw_map if(@index == 1)
      draw_tel if(@index == 2)
      draw_radio if(@index == 3)
    end
    
    #> Dessin de la scene par default
    def draw_def
      @heures.visible = true
      @dots.visible = true
      @minutes.visible = true
      @jour.visible = true
    end
    
    #> Dessin de la scene de la map
    def draw_map
    end
    
    #> Dessin de la scene du telephone
    def draw_tel
      @tel_selector.visible = true
      @name1.visible = @name2.visible = @name3.visible = @name4.visible = true
      @sub_name1.visible = @sub_name2.visible = @sub_name3.visible = @sub_name4.visible = true
      #Nom 1
      @name1.text = @text_name[0+(4*@tel_counter)][0]
      @name1.text += " :" if(@name1.text != "")
      @sub_name1.text = @text_name[0+(4*@tel_counter)][1]
      if(@text_name[0+(4*@tel_counter)][2] == 0)
        @name1.text = "----------"
        @sub_name1.text = ""
      end
      #Nom 2
      @name2.text = @text_name[1+(4*@tel_counter)][0]
      @name2.text += " :" if(@name2.text != "")
      @sub_name2.text = @text_name[1+(4*@tel_counter)][1]
      if(@text_name[1+(4*@tel_counter)][2] == 0)
        @name2.text = "----------"
        @sub_name2.text = ""
      end
      #Nom 3
      @name3.text = @text_name[2+(4*@tel_counter)][0]
      @name3.text += " :" if(@name3.text != "")
      @sub_name3.text = @text_name[2+(4*@tel_counter)][1]
      if(@text_name[2+(4*@tel_counter)][2] == 0)
        @name3.text = "----------"
        @sub_name3.text = ""
      end
      #Nom 4
      @name4.text = @text_name[3+(4*@tel_counter)][0]
      @name4.text += " :" if(@name4.text != "")
      @sub_name4.text = @text_name[3+(4*@tel_counter)][1]
      if(@text_name[3+(4*@tel_counter)][2] == 0)
        @name4.text = "----------"
        @sub_name4.text = ""
      end
    end
    
    #> Dessins dela scene quand le joueur appele quelqu'un
    def draw_message
      @running = false
      $game_variables[101] = @tel_index+1
      $game_temp.common_event_id = 51
    end
    
    #> Dessin de la scene de la radio
    def draw_radio
      @bar_freq.visible = true
      @text_descr_radio.visible = true
      @text_nom_radio.visible = true
      draw_freq
    end
    
    #> Dessin des fréquences
    def draw_freq
      @text_nom_radio.text = ""
      @text_descr_radio.multiline_text = ""
      @nom_radio.size.times do |id|
        if @nom_radio[id][1] == @freq
          @text_nom_radio.text =  @nom_radio[id][0]
          @Music = Audio.bgm_play(@nom_radio[id][2])
          if(@descr_radio[id].size > @sub_freq_counter)
            @text_descr_radio.multiline_text =  @descr_radio[id][@sub_freq_counter]
          else
            @freq_counter = 0
            @sub_freq_counter = 0
            draw_freq
          end
        end
      end
    end
    
    #> Fin de la scene
    def dispose
      super
      @viewport.dispose
    end
    
  end
end