#noyard
module GamePlay
  class Skill_Learn < Base
    Skill_Learn = "Skill_Learn"
    Gender = ["battlebar_a", "battlebar_m", "battlebar_f"]
    Level = [-500,254,270]
    include UI
    attr_accessor :learnt
    def initialize(pokemon, skill_id)
      super(false, 20000)
      @viewport = select_view(view(:main, 19000))
      @viewport.visible = false
      @background = Sprite.new(@viewport).set_bitmap(Skill_Learn, :interface)
      @pokemon = pokemon
      @leveln = 0
      if(@pokemon.level >= 100)
        @leveln = Level[0]
      elsif(@pokemon.level >= 10)
        @leveln = Level[1]
      else(@pokemon.level <=9)
        @leveln = Level[2]
      end
      init_info_pokemon
      @skill_list = Array.new(5)
      4.times do |i|
        #@skill_list[i] = init_skill(34 + 128 * (i % 2), i > 1 ? 146 : 98)#, 126, 46, 3)
        @skill_list[i] = init_skill(0, 0 + 20*i)#, 126, 46, 3)
      end
      @skill_list[4] = init_skill(0, 94)#(98, 194)
      init_skill_descr
      @selector = Sprite.new(@viewport).set_bitmap("cursor_black", :interface)
      @selector.x = 18
      @skill_learn = PFM::Skill.new(skill_id)
      @skills = @pokemon.skills_set
      @index = 0
      @phase = 0
      @memory = 0
      #Icone Pokemon
      @frameicon = 0
      character = sprintf("%03d%s_%d",@pokemon.id,@pokemon.shiny ? "s" : nil,@pokemon.form)
      @character = Sprite.new(@viewport)
      @character.bitmap = RPG::Cache.character(character)
      @character.set_position(22,0)
      @character.src_rect.set(0,0,16,20)
      @character.zoom = 2
      #End
      @running = true
      @learnt = false
    end

    def main_begin
      super
      message_start
    end

    def main_end
      super
      if(@__last_scene.class == Party_Menu)
        $scene = @__last_scene.__last_scene
      end
      Graphics.transition if $game_temp.in_battle
    end

    def update
      return unless super
      if (@phase == 0)
        if (Input.trigger?(:UP))
          @memory = 4 if(@index == 0)
          @index -= 1
          @index = 5 if(@index < 0)
          draw_selector
          draw_skill_descr
        elsif (Input.trigger?(:DOWN))
          @memory = 4 if(@index == 4)
          @index += 1
          @index = 0 if(@index > 5)
          draw_selector
          draw_skill_descr
        elsif (Input.trigger?(:LEFT))
          (@index <= 4 ) ? @index = 0 : @index = @memory
          draw_selector
          draw_skill_descr
        elsif (Input.trigger?(:RIGHT))
          @memory = @index if(@index != 5)
          @index = 5
          draw_selector
          draw_skill_descr
        elsif (Input.trigger?(:A))
          if (@index < 4)
            @memory = @index
            $game_system.se_play($data_system.decision_se)
            #Graphics.wait(5)
            @skill_select = @index
            change_phase
          else
            message_end
          end
        elsif (Input.trigger?(:B))
          message_end
        end
      else
        if (Input.trigger?(:UP))
          @index = 0 if @index == 1
          draw_selector
        elsif (Input.trigger?(:DOWN))
          @index = 1 if @index == 0
          draw_selector
        elsif (Input.trigger?(:A))
          @index == 0 ? forget : change_phase
        elsif (Input.trigger?(:B))
          change_phase
        end
      end
      #Animation Icon
      if(@frameicon >= 20)
        @character.src_rect.set(0,0,16,20)
        @frameicon = 0
      elsif(@frameicon == 10)
        @character.src_rect.set(16,0,16,16)
      end
      @frameicon += 1
      #End
    end

    def message_start
      @message_window.visible = true if $game_temp.in_battle
      if (@pokemon.skills_set.size < 4)
        @pokemon.learn_skill(@skill_learn.id)
        display_message(_parse(22, 106, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
          ::PFM::Text::MOVE[1] => @skill_learn.name))
        @learnt = true
        @running = false
      else
        c = display_message(_parse(22, 99, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
          ::PFM::Text::MOVE[1] => @skill_learn.name), 1, _get(23, 85), _get(23, 86))
        if (c == 0)
          display_message_and_wait(_parse(22, 100))
          #@message_window.visible = false if $game_temp.in_battle
          if (@viewport.visible == false)
            Graphics.freeze
            draw_selector
            draw_info_pokemon
            draw_skills
            draw_skill_descr
            @viewport.visible = true
            Graphics.transition
          end
        elsif (c == 1)
          message_end
        end
      end
    end

    def message_end
      c = display_message(_parse(22, 102, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
          ::PFM::Text::MOVE[1] => @skill_learn.name), 1, _get(23, 85), _get(23, 86))
      if (c == 0)
        display_message_and_wait(_parse(22, 103, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
          ::PFM::Text::MOVE[1] => @skill_learn.name))
        @running = false
      elsif (c == 1)
        message_start
      end
    end

    def forget
      old_skill = @skills[@skill_select]
      @pokemon.replace_skill_index(@skill_select, @skill_learn.id)
      display_message_and_wait(_parse(22, 101, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
        ::PFM::Text::MOVE[1] => old_skill.name, ::PFM::Text::MOVE[2] => @skill_learn.name))
      @learnt = true
      @running = false
    end

    def change_phase
      @index = 0
      if (@phase == 0)
        5.times do |i|
          @skill_list[i].visible = false
        end
        #@skill_descr.set_position(41, 75)
        @phase = 1
      else
        @index = @memory
        5.times do |i|
          @skill_list[i].visible = true
        end
        #@skill_descr.set_position(41, 75)#(82, 12)
        @phase = 0
      end
      draw_selector
      draw_skill_descr
    end

    def draw_selector
      if (@phase == 0)
        if (@index == 5)
        else
        end
        case @index
        when 0, 1, 2, 3
          @selector.x = 18
          @selector.y = 34 + 20*@index
        when 4
          @selector.x = 18
          @selector.y = 128
        when 5
          @selector.x = 200
          @selector.y = 145
        end
      else
        if (@index == 0)
          @selector.x = 159
          @selector.y = 123
        else
          @selector.x = 200
          @selector.y = 145
        end
      end
    end
    
    def init_info_pokemon
      # Partie Haute
      stack = @info_pokemon = SpriteStack.new(@viewport)
      stack.push(20, 0, "whitebar").src_rect.set(0, 0, 64 + 12*18, 24)
      #stack.push(54, 16, nil, type: PokemonIconSprite).zoom = 2
      stack.add_text(56, 10, 100, 16, :given_name_upper, type: SymText)
      stack.push(@leveln, 14, "level_n")
      stack.add_text(232, 8, 66, 19, :level_text, 2, type: SymText)
      stack.push(214, 145, "Retour")
    end
    
    def draw_info_pokemon
      @info_pokemon.data = @pokemon
    end
    
    def init_skill(x, y)
      #Attaques
      stack = SpriteStack.new(@viewport, x, y)
      stack.add_text(32, 34, 85, 16, :name_upper, type: SymText)
      stack.push(242, 36, "PP")
      stack.add_text(279, 34, 100, 16, :pp_text_max, type: SymText)
      stack.visible = false
      return stack
    end
    
    def draw_skills
      5.times do |i|
        i == 4 ? skill = @skill_learn : skill = @skills[i]
        @skill_list[i].visible = (@skill_list[i].data = skill) != nil
      end
    end
    
    def init_skill_descr
      #Selection
      stack = @skill_descr_selected = SpriteStack.new(@viewport, 0, 0)
      @skill_name = stack.add_text(117, 52, 85, 16, :name_upper, 1, type: SymText)
      #PP
      stack.push(98, 76, "PP")
      stack.add_text(136, 74, 40, 16, :pp_text_current, type: SymText)
      stack.add_text(172, 74, 40, 16, "/")
      stack.add_text(193, 74, 40, 16, :pp_text_max, type: SymText)
      #oublier
      stack.add_text(173, 123, 60, 16, "OUBLIER ?")
      stack.visible = false
      #Default
      stack = @skill_descr = SpriteStack.new(@viewport, 0, 0)
      stack.push(32, 174, nil, type: TypeSprite)
      stack.push(32, 192, nil, type: CategorySprite)
      stack.add_text(264, 172, 42, 16, :power_text, 1,  type: SymText)
      stack.add_text(264, 190, 42, 16, :accuracy_text, 1,  type: SymText)
      stack.add_text(12, 212, 296, 32, :description,  type: SymMultilineText)
      stack.add_text(16, 156, 68, 16, "TYPE/")
      stack.add_text(196, 174, 68, 16, "FOR/")
      stack.add_text(196, 192, 68, 16, "PRE/")
      stack.visible = false
    end
    
    def draw_skill_descr
      @skill_descr_selected.visible = false if @skill_descr_selected.visible
      @skill_descr.visible = false if @skill_descr.visible
      if (@phase == 0)
        return if @index == 5
        @index == 4 ? skill = @skill_learn : skill = @skills[@index]
      else
        return if @index == 1
        skill = @skills[@skill_select]
        @skill_descr_selected.visible = (@skill_descr_selected.data = skill) != nil
      end
      @skill_descr.visible = (@skill_descr.data = skill) != nil
    end
=begin
    def dispose
      super
      @viewport.dispose #> For an unknown reason the viewport is disposed :v
    end
=end
  end
end