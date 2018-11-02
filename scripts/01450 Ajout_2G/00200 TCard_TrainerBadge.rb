#noyard
module GamePlay
  class TBadge < Base
    TC_Girl = "TCard/Trainer_Card_F_Badge"
    TC_Boy = "TCard/Trainer_Card_M_Badge"
    Badge = "TCard/Trainer_Badge"
    Animation = "TCard/Trainer_Badge_Anim"
    Champions = "TCard/Trainer_Champions"
    include Text::Util
    include UI
    def initialize
      super
      @viewport = Viewport.create(:main, 1000)
      init_text(0, @viewport)
      #> Background
      @background_badge = Sprite.new(@viewport)
      if($trainer.playing_girl)
        @background_badge.bitmap=RPG::Cache.interface(TC_Girl)
      else
        @background_badge.bitmap=RPG::Cache.interface(TC_Boy)
      end
      #-_-_-_-_-# Variables Globale #-_-_-_-_-#
      # Les variables ci-dessous ne doivent pas
      #  être changé sauf si vous êtes sûr de
      #          ce que vous faites ! 
      #-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-#
      #> Counter animations badge
      @counter = 0
      #> Frame d'animation du badge
      @frame = 0
      #-_-_-_-_-#  Custom.  #-_-_-_-_-#
      #   A partir de ce niveau, les
      # variables peuvent être modifiés
      #  pour customiser l'interface.
      #-_-_-_-_-# Variables #-_-_-_-_-#
      @speed_frame = 9    #> Vitesse de l'animation de badge
      @time_badge = 11    #> Temps d'arrêt sur la face des badge
      @space_x = 64       #> Espacement "x" entre les icones
      @space_y = 48       #> Espacement "y" entre les icones
      #-_-_-_-_-# Icones #-_-_-_-_-#
      @icon_champ = []
      @icon_badge = []
      @icon_frame = []
      8.times do |i|
        #> Icones champions
        @icon_champ[i] = Sprite.new(@viewport)
        @icon_champ[i].bitmap=RPG::Cache.interface(Champions)
        @icon_champ[i].src_rect.set(46*i,0,46,32)
        #> Icones Badge
        @icon_badge[i] = Sprite.new(@viewport)
        @icon_badge[i].bitmap=RPG::Cache.interface(Badge)
        @icon_badge[i].src_rect.set(32*i,0,32,32)
        @icon_badge[i].visible = false
        #> Icones Frame
        @icon_frame[i] = Sprite.new(@viewport)
        @icon_frame[i].bitmap=RPG::Cache.interface(Animation)
        @icon_frame[i].visible = false
        #> Déplacement des icones en fonction de leurs "i"
        if(i <= 3)
          @icon_champ[i].set_position(50+@space_x*i,176)
          @icon_badge[i].set_position(32+@space_x*i,176)
          @icon_frame[i].set_position(32+@space_x*i,176)
        else
          @icon_champ[i].set_position(50+@space_x*(i-4),176+@space_y)
          @icon_badge[i].set_position(32+@space_x*(i-4),176+@space_y)
          @icon_frame[i].set_position(32+@space_x*(i-4),176+@space_y)
        end
      end
      #-_-_-_-_-# Textes #-_-_-_-_-#
      add_text(32,32,136,16, $trainer.name) #> Nom du joueur
      add_text(48+32,40+24,136,16, sprintf("%05d",$trainer.id%100000)) #> Id joueur
      add_text(0+32,72+24,136,16, _get(34,7)) #> ARG.
      add_text(52+32,72+24,136,16, _parse(34,8, NUM7R => $pokemon_party.money.to_s), 2) #> Argent
    end
    
    def update
      @counter +=1
      if(@frame == 0)
      if(@counter == @time_badge)
        @counter = 0
        @frame += 1
        @frame = 0 if(@frame > 3)
        draw_frame
      end
    else
      if(@counter == @speed_frame)
        @counter = 0
        @frame += 1
        @frame = 0 if(@frame > 3)
        draw_frame
      end
    end
      if Input.trigger?(:A)
        @running = false
      end
      if Input.trigger?(:B)
        return_to_scene(Menu)
      end
      if (Input.trigger?(:LEFT))
        @running = false
      end
    end
    
    def draw_frame
      8.times do |i|
        if(@frame == 0)
          @icon_badge[i].visible = true if($game_switches[130+i] == true)
          @icon_frame[i].visible = false
        end
        if(@frame == 1)
          @icon_badge[i].visible = false
          @icon_frame[i].visible = true if($game_switches[130+i] == true)
          @icon_frame[i].src_rect.set(0,0,32,32)
        end
        if(@frame == 2)
          @icon_frame[i].src_rect.set(32,0,32,32)
        end
        if(@frame == 3)
          @icon_frame[i].src_rect.set(64,0,32,32)
        end
      end
    end
    
    #> Fin de la scene
    def dispose
      super
      #@background_badge.dispose
      @viewport.dispose
    end
    
  end
end