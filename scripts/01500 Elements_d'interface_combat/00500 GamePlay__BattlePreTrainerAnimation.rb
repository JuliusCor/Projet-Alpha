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
    MaxDelta = 120
    #BALL_Animation = [0, 270, 0, 225, 0, 180, 0, 135, 1, 90, 1, 45, 1, 0, 1, 315, 2, 270, 2, 225, 2,180, 2, 135, 2, 90, 2, 45, 2, 0, 2, 30, 2, 60, 2, 90, 3, 90, 3, 135, 3, 180, 3,225, 3, 270, 3, 315, 3, 0, 3, 0, 3, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 5, 0]
    #===
    #>initialize 
    # Initialisatation du module
    #---
    #E : viewport : Viewport sur lequel les sprites seront affichés
    #===
    def initialize(viewport, screenshot)
      @unlocked = false
      @bg_delta = 0
      
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
      @blackouts = Array.new(6) do |i| ::RPG::Cache.transition(Files[4]+(5-i).to_s) end
      2.times do @blackouts << @blackouts[5] end
      @blackout_counter = 0
    end
    
    #===
    #>Mise à jour de la scène
    #===
    def update
      if(@screen)
        update_map_transition
        return true
      end
      #>Déplacement du fond
      #@background.set_position(@bg_delta * DX + 160, @bg_delta * DY + 120)
      #@bg_delta += spd_calculation
      #@bg_delta -= MaxDelta if @bg_delta >= MaxDelta
      #Déplacement des halos
      #Mise à jour du dégradé
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
      @blackout_counter += 1
      generate_blackout_matrix unless @blackout_matrix
      @blackouts.size.times do |i|
        x = 10 - @blackout_counter / 3 + i
        next if x >= 10 or x < 0
        bmp = @blackouts[i]
        8.times { |y| @blackout_matrix[x][y].bitmap = bmp }
      end
      dispose_map_transition if(@blackout_counter >= 100)
    end
    # Generate the blackout matrix
    def generate_blackout_matrix
      viewport = Viewport.create(:main, 10_000)
      delta = 32
      @blackout_matrix = Array.new(10) do |x|
        Array.new(8) do |y|
          Sprite.new(viewport).set_position(x * delta, y * delta)
        end
      end
    end
    # Dispose the map transition
    def dispose_map_transition
      @screen.bitmap.dispose
      @screen.dispose
      @screen = nil
      @blackouts = nil
      @blackout_matrix[0][0].viewport.dispose
      @blackout_matrix = nil
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
