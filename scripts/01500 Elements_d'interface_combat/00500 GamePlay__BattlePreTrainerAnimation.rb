# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2015
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Affichage de l'animation pré combat du dresseur
module GamePlay
  class BattlePreTrainerAnimation
    Files = ["back","battle_deg","battle_halo1","battle_halo2","black_out0"]
    Back_Player = "Back_Player"
    DegrOffset = 90
    #BALL_Animation = [0, 270, 0, 225, 0, 180, 0, 135, 1, 90, 1, 45, 1, 0, 1, 315, 2, 270, 2, 225, 2,180, 2, 135, 2, 90, 2, 45, 2, 0, 2, 30, 2, 60, 2, 90, 3, 90, 3, 135, 3, 180, 3,225, 3, 270, 3, 315, 3, 0, 3, 0, 3, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 5, 0]
    #===
    #>initialize 
    # Initialisatation du module
    #---
    #E : viewport : Viewport sur lequel les sprites seront affichés
    #===
    def initialize(viewport, screenshot)
      @unlocked = false
      @viewport = viewport
      @viewport.color.set(255, 255, 255, 0)
      @background = Sprite.new(viewport)
        .set_bitmap(Files[0], :transition)
      
      #1
      @battler = ::Sprite.new(viewport)
        .set_bitmap($game_temp.enemy_battler[0] + "_sha", :battler)
      @battler.x = 0 - 112
      @battler.y = -4
      #2
      @battler2 = ::Sprite.new(viewport)
        .set_bitmap($game_temp.enemy_battler[0] + "", :battler)
      @battler.ox = @battler2.ox = @battler.bitmap.width/2
      @battler2.x = 250
      @battler2.opacity = 0
      @battler2.y = -4
      #> Dresseur joueur
      @back_player=Sprite.new(@viewport)
      @back_player.bitmap=RPG::Cache.interface(Back_Player)
      @back_player.x = 320 + 112
      @back_player.y = 96
      @back_player.z = 44000
      if($trainer.playing_girl)
        @back_player.src_rect.set(96,96,96,96)
      else
        @back_player.src_rect.set(0,96,96,96)
      end
      #>Compteur de la vitesse
      @spd_counter = 0
      @unlock_counter = -20
      @battler_wait = 0
      @back_wait = 0
      #>Transition d'entrée
      @screen = ::Sprite.new(viewport)
      @screen.bitmap = screenshot
      @screen.zoom = Graphics.width / screenshot.width.to_f
      #> Transition avant combat
      #> Variable
      @counter = 0
      @trans_speed = 7
      @force = 16
      @switch = 0
      @frame_x = 0
      @frame_y = 0
      #> Sprite
      @transition = Sprite.new(@viewport)
      @transition.bitmap = RPG::Cache.transition("Transition")
      @transition.src_rect.set(0,0,320,288)
      @transition.visible = false
      #> FIN
    end
    
    #===
    #>Mise à jour de la scène
    #===
    def update
      if(@screen)
        update_map_transition
        return true
      end
      #>Mise à jour du joueur
      if(@back_player.x > 32)
        @back_player.x -= 4
      elsif(@back_wait < 5)
        @back_wait += 1
      elsif(@back_wait == 5)
        Audio.se_play("Audio/SE/2G_Bip_Battle.wav")
        @back_wait += 1
      else
        if($trainer.playing_girl)
          @back_player.src_rect.set(96,0,96,96)
        else
          @back_player.src_rect.set(0,0,96,96)
        end
      end
      #>Mise à jour du battler
      if(@battler.x < 250)
        @battler.x += 3.5
        @battler.x = 250 if(@battler.x >= 250)
      elsif(@battler_wait < 5)
        @battler_wait += 1
      elsif(@battler.opacity > 0)
        @battler.opacity = 0
        @battler2.opacity = 255
      elsif(@unlocked and @battler2.x < 480)
        if(@unlock_counter < 0)
          @battler2.x -= 0
          @unlock_counter += 1
        else
          @battler2.x += 3.4809
        end
      else
        return false
      end
      return true
    end
    #===
    #>Mise à jour de la transition de map
    #===
    def update_map_transition
      if(@counter == @trans_speed*12+6)
        @transition.visible = true
      elsif(@counter >= @trans_speed*12+6 and @counter <= 500)
        @transition.src_rect.set(0+320*@frame_x,0+288*@frame_y,320,288)
        if(@switch == 2)
          @frame_x += 1
          if(@frame_x >= 4)
            @frame_y += 1
            @frame_x = 0
          end
          @switch = 0
        else
          @switch += 1
        end
        if(@frame_y == 4)
          @transition.src_rect.set(1280,864,320,288)
          @counter = 980
        end
      #3.0
      elsif(@counter >= @trans_speed*11 and @counter <= @trans_speed*12)
        Graphics.brightness += @force
      elsif(@counter >= @trans_speed*10 and @counter <= @trans_speed*11)
        Graphics.brightness -= @force
      elsif(@counter >= @trans_speed*9 and @counter <= @trans_speed*10)
        @viewport.color.alpha -= @force
      elsif(@counter >= @trans_speed*8 and @counter <= @trans_speed*9)
        @viewport.color.alpha += @force
      #2.0
      elsif(@counter >= @trans_speed*7 and @counter <= @trans_speed*8)
        Graphics.brightness += @force
      elsif(@counter >= @trans_speed*6 and @counter <= @trans_speed*7)
        Graphics.brightness -= @force
      elsif(@counter >= @trans_speed*5 and @counter <= @trans_speed*6)
        @viewport.color.alpha -= @force
      elsif(@counter >= @trans_speed*4 and @counter <= @trans_speed*5)
        @viewport.color.alpha += @force
      #1.0
      elsif(@counter >= @trans_speed*3 and @counter <= @trans_speed*4)
        Graphics.brightness += @force
      elsif(@counter >= @trans_speed*2 and @counter <= @trans_speed*3)
        Graphics.brightness -= @force
      elsif(@counter >= @trans_speed and @counter <= @trans_speed*2)
        @viewport.color.alpha -= @force
      elsif(@counter <= @trans_speed)
        @viewport.color.alpha += @force
      #end
      elsif(@counter >= 1000)
        dispose_map_transition
      end
      @viewport.update if @screen
      @counter += 1 if(@counter <= 1000)
    end
    # Dispose the map transition
    def dispose_map_transition
      @screen.bitmap.dispose
      @screen.dispose
      @screen = nil
      @transition.dispose
      #@blackouts = nil
      #@blackout_matrix[0][0].viewport.dispose
      #@blackout_matrix = nil
    end
    #===
    #>Déverrouillage pour finir l'animation
    #===
    def unlock
      @unlocked = true
    end
    #===
    #>Variateur de vitesse
    #===
    def spd_calculation
      @spd_counter += 1
      if(@spd_counter >= 600)
        @spd_counter -= 600
      end
      return (2.5 - Math::cos(Math::PI * @spd_counter / 300))
    end
    #===
    #>Lancement des balles
    #===
    def launch_balls
    end
    #===
    #>dispose
    # Effacement de tout le stuff affiché par la scene
    #===
    def dispose
      @background.dispose
      @background = nil
      @battler.dispose
      @battler = nil
      @battler2.dispose
      @battler2 = nil
      @back_player.dispose
    end
  end
end
