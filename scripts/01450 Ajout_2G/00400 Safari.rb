# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Maxoumi
# Merci : SMB64 pour sa grande aide. Nuri Yuri pour PSDK
# Date: 2018
# Description: PoKéMatos
module GamePlay
  class Safari < Base
      include UI
      include Text::Util
      attr_accessor :text_name
      attr_accessor :screenshot
    #def initialize(mode=:menu)
    def initialize
      super()
      @screenshot = Graphics.snap_to_bitmap
      @viewport = Viewport.create(:main, 1000)
      @viewport.color.set(255, 255, 255, 0)
      init_text(0, @viewport)
      #-_-_-# Initialisation #-_-_-#
      init_sprite
      #> Variables
      @counter = 0
      @frame_x = 0
      @frame_y = 0
      @switch = 0
      @trans_speed = 7
      @force = 16
      #-_-_-_-_-_-_-_-_# LISTE PKM #-_-_-_-_-_-_-_-#
      # Modifiez le tableau ci-dessous pour        #
      # personnalisé la liste des pkm du safari    #
      #-_-_-_-_-_-_-_-_# LISTE PKM #-_-_-_-_-_-_-_-#
      @pkm_safari = [
      #> Tableau des ids des pokémon disponible dans le parc safari
      #> ID POKEMON | CHANCE
      [29,60],  # => Nidoran F
      [30,40],  # => Nidorina
      [32,60],  # => Nidoran M
      [33,40],  # => Nidorino
      [46,60],  # => Paras
      [47,40],  # => Parasect
      [48,50],  # => Mimitoss
      [49,30],  # => Aeromite
      [102,30], # => Noeunoeuf
      [104,40], # => Osselait
      [105,30], # => Ossatueur
      [111,40], # => Rhinocorne
      [111,20], # => Rhinoferos
      [113,10], # => Leveinard
      [114,40], # => Saquedeneu
      [115,10], # => Kangourex
      [123,15], # => Insecateur
      [127,15], # => Scarabrute
      [128,10]] # => Tauros
    end
    
    #> Initialisation des Sprites
    def init_sprite
      #> Screenshot du jeu
      @screen = Sprite.new(@viewport)
      @screen.bitmap = @screenshot
      @screen.zoom = Graphics.width / screenshot.width.to_f
      #> Battleback du combat
      @back = Sprite.new(@viewport)
      @back.bitmap=RPG::Cache.interface("battle/back_battle")
      @back.visible = false
      #> Transition d'entrée
      @transition = Sprite.new(viewport)
      @transition.bitmap = RPG::Cache.transition("Transition")
      @transition.src_rect.set(0,0,320,288)
      @transition.visible = false
    end

    #> Update de la scene
    def update
      update_transition if(@counter <= 1000)
    end

    #> Update de la transition
    def update_transition
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
      end
      @viewport.update if @screen
      @counter += 1 if(@counter <= 1000)
    end

    #> Fin de la scene
    def dispose
      super
      @viewport.dispose
    end
    
  end
end