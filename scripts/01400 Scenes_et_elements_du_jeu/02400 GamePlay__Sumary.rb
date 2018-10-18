# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2015
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Définition du résumé d'un Pokémon de l'équipe
module GamePlay
  class Sumary < Base
    BGS = ["Detail_A","Detail_A_Egg","Detail_B","Detail_C","Detail_D","Detail_E","Detail_F"]
    def initialize(pokemon, z=1001, mode=:view, party=[], extend_data = nil)
      super(false, z*10)
      @pokemon = pokemon
      @mode = mode
      @party = party
      @index = (mode==:skill ? 2 : 0)
      @sub_index = 0
      @sub_index2 = nil
      @skill_selected = -1
      @skill_index = 0
      @extend_data = extend_data
      
      @viewport = Viewport.create(:main, z)
      
      @bg = Sprite.new(@viewport)
      #> Init the stacks
      (@stacks = [
        A.new(viewport),
        B.new(viewport),
        C.new(viewport),
        D.new(viewport),
        E.new(viewport),
        F.new(viewport)
      ]).each do |stack| stack.visible = false end
      @last_stack = @stacks.first
      #> Top sprites (always shown)
      @sprite = Sprite.new(@viewport)
        .set_position(2, 2)
      @sprite_team = Array.new(6) do |i|
        Sprite.new(@viewport)
        .set_position(-500, -500 + i * 28 - 32) # + 16, 48
      end
      @sprite_team[0].set_position(-500, -500 - 32)
      @ball = Sprite.new(@viewport)
        .set_position(-500, -500)
      @skill_selector = Sprite::WithColor.new(@viewport)
        .set_bitmap("cursor_black", :interface)
        .set_position(18, 34)
        .set_color(ShaderColNone)
      @skill_selector2 = Sprite.new(@viewport)
        .set_bitmap("cursor_black2", :interface)
        .set_position(18, 34)
      @leveln = Sprite.new(@viewport)
        .set_bitmap("level_n", :interface)
        .set_position(-500, 14)
      character = sprintf("%03d%s_%d",@pokemon.id,@pokemon.shiny ? "s" : nil,@pokemon.form)
      @w = 1
      @counter = 0
      @dispose = 0
      @crywait = 0
      pokemon_cry
    end
    
    def draw_scene
      draw_party
      @skill_selector.visible = @skill_selector2.visible = false
      index = @pokemon.egg ? 0 : @index
      @ball.bitmap = RPG::Cache.ball(@pokemon.ball_sprite)
      @ball.src_rect.set(0,78,16,26)
      stack = @stacks[index]
      @last_stack.data = nil if stack != @last_stack
      stack.data = @pokemon
      @last_stack = stack
      @sub_index2 = nil if index != 2
      case index
      when 0
        @bg.bitmap=RPG::Cache.interface(BGS[@pokemon.egg ? 1 : 0])
      when 1
        @bg.bitmap=RPG::Cache.interface(BGS[2])
        if(@dispose == 1)
          @sprite_test.dispose
          @dispose = 0
        end
        @sprite.visible = true if(@sprite.visible != true)
        @leveln.x = -500
      when 2
        @bg.bitmap=RPG::Cache.interface(BGS[3])
        @sprite.visible = false if(@sprite.visible != false)
        if(@dispose == 1)
          @sprite_test.dispose
          @dispose = 0
        end
        character = sprintf("%03d%s_%d",@pokemon.id,@pokemon.shiny ? "s" : nil,@pokemon.form)
        @sprite_test = Sprite.new
        @sprite_test.bitmap = RPG::Cache.character(character)
        @sprite_test.x = 22
        @sprite_test.z = 10000
        @sprite_test.zoom = 2
        @dispose = 1
        draw_C(stack)
      when 3
        @bg.bitmap=RPG::Cache.interface(BGS[4])
      when 4
        @sprite.visible = true if(@sprite.visible != true)
        #@sprite.src_rect.set(0, 0, 112, 112)
        @bg.bitmap=RPG::Cache.interface(BGS[5])
      when 5
        @sprite.visible = false if(@sprite.visible != false)
        @bg.bitmap=RPG::Cache.interface(BGS[6])
      end
    end
    
    def update
      super
      if(@mode==:view)
        if(@index != 2 and @index != 6)
          if(Input.trigger?(:DOWN) and @crywait == 0)
            move_party(1)
            pokemon_cry
          elsif(Input.trigger?(:UP) and @crywait == 0)
            move_party(-1)
            pokemon_cry
          elsif(Input.trigger?(:RIGHT))
            if(@index == 0 or @index == 3)
              @index += 1
            elsif(@index == 5)
              @index = 5
            else
              @index+=2
              if(@index > 5)
                @index = 0
              end
            end
            draw_scene
          elsif(Input.trigger?(:LEFT))
            if(@index == 1 or @index == 4)
              @index -= 1
            elsif(@index == 5)
              @index = 5
            else
              @index-=2
              if(@index < 0)
                @index = 4
              end
            end
            draw_scene
          end
          
        end
        if(Input.trigger?(:A))
          if(@index==1)
            @index=2
            draw_scene
          elsif(@index==4)
            @index=5
            draw_scene
          elsif(@sub_index2 and @index==2)
            choice_skill
            ss=@pokemon.skills_set
            if(ss[@sub_index2] and ss[@sub_index])
              ss[@sub_index2],ss[@sub_index]=ss[@sub_index],ss[@sub_index2]
              @sub_index2=nil
              draw_scene
            end
          elsif(@index==2 and !$game_temp.in_battle)
            $game_system.se_play($data_system.decision_se)
            @sub_index2=@sub_index
            draw_scene
          end
        elsif(Input.trigger?(:B))
          if(@index==2)
            @index=1
            draw_scene
          elsif(@index==5)
            @index=4
            draw_scene
          elsif(@crywait == 0)
            @running=false
          end
        end
      end
      if(@index==2)
        if(Input.trigger?(:UP))
          @sub_index-=1
          @sub_index=3 if @sub_index<0
          draw_scene
        elsif(Input.trigger?(:DOWN))
          @sub_index+=1
          @sub_index=0 if @sub_index>3
          draw_scene
        elsif(@mode==:skill)
          if(Input.trigger?(:A))
            if skill = @pokemon.skills_set[@sub_index]
              if(@extend_data)
                if(@extend_data[:on_skill_choice].call(skill))
                  @extend_data[:on_skill_use].call(skill) if @extend_data[:on_skill_use]
                  @extend_data[:skill_selected] = @skill_selected = @sub_index 
                  @running=false
                else
                  display_message(_parse(22, 108))
                end
              else
                @skill_selected=@sub_index 
                @running=false
              end
            end
          elsif(Input.trigger?(:B))
            @skill_selected=-1
            @running=false
          end
        end
      end
      #> Custom
      if(@dispose == 1)
        @sprite_test.src_rect.width = @sprite_test.bitmap.width/4
        @sprite_test.src_rect.x = @w * @sprite_test.src_rect.width
        @counter += 1
        @w += 1 if @counter == 20
        @counter = 0 if @counter == 20
        @w = 1 if @w > 2
      end
      if(@crywait > 0)
        @crywait -= 1
      end
    end
    
    def pokemon_cry
      $game_system.cry_play(@pokemon.id)
      @crywait = 60
    end
    
    def choice_skill
      Audio.se_play("Audio/SE/2G_Switch.mp3")
      @skill_selector.visible = false
      @skill_selector2.visible = false
      Graphics.wait(30)
      @skill_selector.visible = true
      @skill_selector2.visible = false
    end
    
    def draw_C(stack)
      if(@pokemon.level>99)
          @leveln.x = -500
        elsif(@pokemon.level>9)
          @leveln.x = 254
        else(@pokemon.level<10)
          @leveln.x = 270
        end
      @skill_selector.visible = true
      @skill_selector.y = 34 + 32 * @sub_index
      @skill_selector.x = 18
      if(@sub_index2)
        @skill_selector2.visible = true
        @skill_selector2.set_position(@skill_selector.x, 34 + 32 * @sub_index2)
        #@skill_selector.set_color(ShaderColSwitch)
      else
        @skill_selector.set_color(ShaderColNone)
      end
      skill = @pokemon.skills_set[@sub_index]
      stack.skill_stack.each_value do |sprite| sprite.data = skill end
    end
  
    def draw_party
      draw_party_proc = proc do |i, pos|
        if(pkm = @party[(i + pos) % @party.size])
          @sprite_team[i].bitmap = pkm.icon
          @sprite_team[i].visible = true
        end
      end
      # Update the party and Pokemon sprite
      @sprite.bitmap = @pokemon.battler_face
      @sprite.src_rect.set(0, 0, 112, 112)
      @sprite_team.each do |i| i.visible = false end
      if(pos = @party.index(@pokemon))
        @party.size.times do |i| draw_party_proc.call(i, pos) end
      end
    end
    
    def dispose
      super
      @viewport.dispose
    end
    
  end
end