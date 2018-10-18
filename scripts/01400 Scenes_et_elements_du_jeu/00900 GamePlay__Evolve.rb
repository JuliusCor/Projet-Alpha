#noyard
module GamePlay
  class Evolve < Base
      BackNames = "White_Background"
      EvolveMusic = "Audio/ME/2G_Evolution.mp3"
      EvolvedMusic = "Audio/ME/2G_Evolution_Fin.mp3"
    attr_accessor :evolved
    def initialize(pkmn, id, forced = false)
      super()
      @pokemon = pkmn
      @clone = pkmn.clone
      @clone.id = id
      #check_alola_evolve(@clone)
      @forced = forced
      #> Génération du Background
      @viewport = select_view(view(:main, @message_window.z - 1))
      #> Background
      @background = background(BackNames, :interface)
      #> Sprite du Pokémon non évolué
      @sprite_pokemon = ShaderedSprite.new(@viewport)
        .set_bitmap(pkmn.battler_face)
        .set_origin(56, 56)
        .set_position(160, 120)
      #> Sprite du Pokémon évolué
      @sprite_clone = ShaderedSprite.new(@viewport)
        .set_bitmap(@clone.battler_face)
        .set_origin(56, 56)
        .set_position(160, 120)
      @sprite_pokemon.shader = Shader.new(Shader.load_to_string('Black_and_white'))
      @sprite_clone.shader = Shader.new(Shader.load_to_string('Black_and_white'))
      @sprite_clone.opacity = 0
      @evolved = false
      @step = 0
      @counter = 0
      @wait = 0
      $game_system.bgm_memorize2
      Audio.bgm_stop
    end
    
    def update
      super()
      return if $game_temp.message_window_showing
      if @step == 0
        @message_window.auto_skip = true
        @message_window.stay_visible = true
        display_message(_parse(31, 0, ::PFM::Text::PKNICK[0] => @pokemon.given_name))
        $game_system.cry_play(@pokemon.id)
        Graphics.wait(80)
        Audio.bgm_play(EvolveMusic)
        @sprite_pokemon.shader.set_float_uniform('tone', Tone.new(0, 0, 0, 255))
        @sprite_clone.shader = @sprite_pokemon.shader
        Graphics.wait(30)
        @step = 1
      elsif @step == 4
        @sprite_pokemon.shader.set_float_uniform('tone', Tone.new(0, 0, 0, 0))
        @sprite_clone.shader = @sprite_pokemon.shader
        $game_system.cry_play(@pokemon.id+1)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(60)
        display_message(_parse(31, 2, ::PFM::Text::PKNICK[0] => @pokemon.given_name_upper,
        ::PFM::Text::PKNAME[1] => @clone.name_upper))
        @message_window.stay_visible = false
        Audio.bgm_play(EvolvedMusic)
        @message_window.auto_skip = true
        display_message(_parse(31, 7, ::PFM::Text::PKNICK[0] => @pokemon.given_name_upper,
        ::PFM::Text::PKNAME[1] => @clone.name_upper))
        Graphics.wait(180)
        Audio.bgm_stop
        while $game_temp.message_window_showing
          @message_window.update
          Graphics.update
        end
        @pokemon.id = @clone.id
        #check_alola_evolve(@pokemon)
        @pokemon.check_skill_and_learn
        #===
        #> Munja évolution de Ningale
        #===
        if @clone.id == 291 and $actors.size < 6 and $bag.has_item?(4)
          $actors << PFM::Pokemon.new(292)
          $bag.remove_item(4)
        end
        @evolved = true
        @step = 5
      else
        if(@step != 0 and @step != 5 and (!@forced and Input.trigger?(:B)))
          release_animation
          @message_window.stay_visible = false
          display_message(_parse(31, 1, ::PFM::Text::PKNICK[0] => @pokemon.given_name))
          @running = false
          $game_system.bgm_restore2
          return
        else
          update_animation
        end
      end
      @wait += 1 if(@step == 3)
    end
    
    def update_animation
      if @step == 1
        #1
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(15)
        #2
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(15)
        #3
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(15)
        #4
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(15)
        @step = 2
      elsif @step == 2
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(5)
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        Graphics.wait(15)
        @counter +=1
        @step = 3 if(@counter == 5)
      elsif @step == 3
        @sprite_clone.opacity = 255
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        if(@wait < 7)
          Graphics.wait(4)
        else
          Graphics.wait(3)
        end
        @sprite_clone.opacity = 0
        (@sprite_clone.opacity == 255) ? @sprite_pokemon.opacity = 0 : @sprite_pokemon.opacity = 255
        if(@wait < 7)
          Graphics.wait(4)
        else
          Graphics.wait(3)
        end
        @step = 4 if(@wait == 14)
      elsif @step == 5
        $game_system.bgm_restore2
        @running = false
      end
      
    end
    
    def release_animation
      @sprite_clone.opacity = 0
      @sprite_pokemon.opacity = 255
      @sprite_pokemon.tone.set(0,0,0,0)
      @background.tone.set(0,0,0,0)
    end
=begin    
    def check_alola_evolve(pokemon)
      return unless $game_switches[::Yuki::Sw::Alola]
      case pokemon.id
      when 26, 103 #Raichu / Noadkoko 
        pokemon.form = 1
      when 105 # Ossatueur
        pokemon.form = 1 if $env.night?
      end
    end
=end
  end
end