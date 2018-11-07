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
      @mode = "transition"
      init_custom
      init_sprite
      $game_system.bgm_play($game_system.battle_bgm)
      @troop_id = PFM::Pokemon_Party.new(true)
      add_text(2, 2, 320, 22, @troop_id.to_s).set_size(8)
    end
    
    #-_-_-_-_-_-_-_-_# CUSTOM #-_-_-_-_-_-_-_-#
    # Modifiez le tableau ci-dessous          #
    # pour personnalisé le parc safari        #
    #-_-_-_-_-_-_-_-_# CUSTOM #-_-_-_-_-_-_-_-#
    def init_custom
      #> Variables
      @current_box_list = $storage.get_box($storage.current_box).select { |element| element }
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
      #> Le niveau des pokémon du parc [min,max]
      @pokemon_range_level = [20,30]
      #> Tableau des ids des pokémon disponible dans le parc safari
      @pkm_safari =
      #> ID POKEMON
      [29,30,32,33,46,47,48,49,30,102,104,105,111,111,113,114,115,123,127,128]
    end

    #> Update de la scene
    def update
      if Input.trigger?(:RIGHT)
      end
      if Input.trigger?(:B)
        @running = false
      end
      update_transition if(@counter <= 1000 and @mode == "transition")
      update_start_battle if(@mode == "start")
    end

    def update_start_battle
      @back_player.x -= 4
      @pokemon_battle_face.x += 3
      @mode = "battle" if(@back_player.x <= 32)
    end

    def start_battle
      @counter = 0
      @mode = "start"
      @back.visible = true
      @back_player.visible = true
      @back_player.x = 320 + 112
      @back_player.y = 96
      @pokemon_battle_face.visible = true
      @pokemon_battle_face.x -= 112
      @pokemon_battle_face.y = 8
    end

    def make_pokemon
      @pkm_safari.shuffle!
      @id = @pkm_safari[0]
      @pokemon_level = rand(((@pokemon_range_level[1]+1)-(@pokemon_range_level[0]-1)))
      @pokemon_level += @pokemon_range_level[0]
      @shiny_shuffle = rand(4097) #> De 0 a 4096
      @shiny_shuffle = @shiny_shuffle/2 if($bag.has_item?(632)) #> Si charme chroma = 2048
      @shiny = 0
      @shiny = 1 if(@shiny_shuffle == 42)
      @gender = rand(2)
      @pokemon_battle_face = Sprite.new(@viewport)
      hue=@shiny
      if(@gender==1)
        str=sprintf("%03d",@id)
        @pokemon_battle_face.bitmap = RPG::Cache.poke_front(str,hue) if RPG::Cache.poke_front_exist?(str,hue)
      else
        str=sprintf("%03d",@id)
        @pokemon_battle_face.bitmap = RPG::Cache.poke_front(str,hue)
      end
      @pokemon_battle_face.visible = false
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
      #> Creation du sprite pokémon
      make_pokemon
      #> Back du joueur
      @back_player=Sprite.new(@viewport)
      @back_player.bitmap=RPG::Cache.interface("battle/Back_Player")
      if($trainer.playing_girl)
        @back_player.src_rect.set(96,96,96,96)
      else
        @back_player.src_rect.set(0,96,96,96)
      end
      @back_player.visible = false
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
        start_battle
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