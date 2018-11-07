# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2015
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Affichage de l'animation pré combat des Pokémon
module GamePlay
  include UI
  class BattlePreWildAnimation < BattlePreTrainerAnimation
    Functions = [
    [:grass_init, :grass_update, :grass_dispose],
    [:nothing_init, :nothing_update, :nothing_dispose]
    ]
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
      if($env.tall_grass? or $env.very_tall_grass?)
        id = 0
      else
        id = 1
      end
      @functions = Functions[id]
      
      @ground = GamePlay::BattleGrounds.new(viewport, false)
      @delta_x = delta_x = 0 - 48 - @ground.x #233 #350
      @delta_y = delta_y = 89 - @ground.y
      @ground.x += delta_x
      @ground.y += delta_y
      i = 0
      sprite = nil
      pkmn = nil
      @enemies = Array.new($game_temp.vs_type) do |i|
        pkmn = $scene.enemy_party.actors[i]
        pkmn.position = -i-1
        sprite = BattleSprite.new(viewport, pkmn)
        sprite.x += delta_x
        sprite.y += delta_y
        sprite.color.alpha = 255
        next(sprite)
      end
      @delta_x /= 30.0
      @delta_y /= 30.0
      #send(@functions[0])
      #>Transition d'entrée
      @screen = ::Sprite.new(viewport)
      @screen.zoom = Graphics.width / screenshot.width.to_f
      @screen.bitmap = screenshot
      @screen.z = -2000
      @counter = 0
      @add = 1000
      @transition = Sprite.new(viewport)
      @transition.bitmap = RPG::Cache.transition("Transition")
      @transition.src_rect.set(0,0,320,288)
      @transition.z = 44001
      @transition.visible = false
      @frame_x = 0
      @frame_y = 0
      @switch = 0
      @trans_speed = 7
      @force = 16
      #> Dresseur joueur
      @back_player=Sprite.new(@viewport)
      @back_player.bitmap=RPG::Cache.interface(Back_Player)
      @back_player.x = 320
      @back_player.y = 96
      @back_player.z = 44000
      if($trainer.playing_girl)
        @back_player.src_rect.set(96,96,96,96)
      else
        @back_player.src_rect.set(0,96,96,96)
      end
    end
    #===
    #>Mise à jour de la scène
    #===
    def update
      if(@screen)
        update_map_transition
        return true
      else
      	nothing_update
      end
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
        @transition.dispose
        @screen.bitmap.dispose
        @screen.dispose
        @screen = nil
        @counter = 119
      end
      @viewport.update if @screen
      @counter += 1 if(@counter <= 1000)
    end
    #===
    #>dispose
    # Effacement de tout le stuff affiché par la scene
    #===
    def dispose
      send(@functions[2])
      i = nil
      @enemies.each do |i|
        i.dispose
      end
      @ground.dispose
    end

    #===
    def del_back
      @back_player.dispose
    end
    #===

    #===
    #>repos_enemy
    # Repositionnement des enemis au bon endroit
    #===
    def repos_enemy
      @enemies.each do |i|
        i.x += 3.47
        @back_player.x -= 3.47
      end
      @ground.x = -100
    end
    #===
    #>recolorise_enemy
    # Recolorisation de l'enemy
    # 
    #===
    def recolorise_enemy
      @enemies.each do |i|
        i.color.alpha -= 10
      end
    end
    #===
    #>Dummy
    #===
    def nothing_init
    end
    
    def nothing_update
      if(@counter <= 90)
      elsif(@unlocked)
        if(@counter <= 200)
          repos_enemy
        elsif(@counter <= 201)
          if($trainer.playing_girl)
	        @back_player.src_rect.set(96,0,96,96)
	      else
	        @back_player.src_rect.set(0,0,96,96)
	      end
        else
          return false
        end
      else
        return false
      end  
      @counter += 1
      return true
    end
    
    def nothing_dispose
    end
    #====
    #>Transition de l'herbe
    #===
    def grass_init
    end
    
    def grass_update
    end
    
    def grass_dispose
    end
    
    def get_sprite(i)
      @enemies[i]
    end
  end
end
