#noyard
module GamePlay
  class StorageUtils
    Background = "box_f"
    Selector = "h_1"
    Party_f = "pkmn_party_f"
    Gender = ["battlebar_a", "battlebar_m", "battlebar_f"]
    Box = ["Renommer", "Thème", "Retour"]
    include UI
    def initialize
      @viewport = Viewport.create(:main, 10000)
      @background = Sprite.new(@viewport).set_bitmap(Background, :pc)
      init_pokemon_box
      init_box_title
      @party_back = Array.new(6) do |i|
        if(i > 2)
          stack = SpriteStack.new(@viewport, 21 + 50 * (i - 3), 201, default_cache: :pc)
        else
          stack = SpriteStack.new(@viewport, 21 + 50 * i, 168, default_cache: :pc)
        end
        stack.push(0, 0, Party_f).visible = false
        stack.push(1, -2, nil)
        next(stack)
      end
      init_pokemon_info
      init_selector
      @message_window = Window_Message.new(@viewport)
      draw_init
    end

    def update
      @message_window.update
    end
    
    def init_box_title
      @box_title = SpriteStack.new(@viewport, 30, 0)
      @box_title.push(0, 0, nil)
      @box_title.visible = false
      @box_title.add_text(0, 4, 116, 16, nil.to_s, 1)
    end
    
    def change_box
      id_theme = $storage.get_box_theme($storage.current_box)
      (stack = @box_title.stack).first.set_bitmap("title_1", :pc)
      stack.last.text = $storage.get_box_name($storage.current_box)
      draw_pokemon_box
    end

    def display_message(str, start=1, *choices)
      $game_temp.message_text = str
      b = true
      $game_temp.message_proc = Proc.new{b = false}
      c = nil
      if(choices.size > 0)
        $game_temp.choice_max = choices.size
        $game_temp.choice_cancel_type = choices.size
        $game_temp.choice_proc = Proc.new{|i|c = i}
        $game_temp.choice_start = start
        $game_temp.choices = choices
      end
      while b
        Graphics.update
        @message_window.update
      end
      Graphics.update
      return c
    end

    def _party_window(*args)
      window=Window_Choice.new(150,args)
      window.z=@viewport.z+1
      window.height += 48
      window.x=320-window.width
      window.y=288-window.height
      disabled=[]
      args.each_index do |i|
        cmd=args[i]
      end
      loop do
        Graphics.update
        window.update
        if window.validated?
          if(disabled.include?(window.index))
            $game_system.se_play($data_system.buzzer_se)
          else
            $game_system.se_play($data_system.decision_se)
            break
          end
        elsif(Input.trigger?(:B))
          window.index=args.size
          break
        end
      end
      index=window.index
      window.dispose
      return index
    end

    def gestion_boite
      ind = _party_window(*Box)
      box_id = $storage.current_box
      if (ind == 0) # Renommer
        $storage.set_box_name(box_id,
        Scene_NameInput.new($storage.get_box_name(box_id), 10, "pc_psdk").main.return_name)
        Graphics.transition
        change_box
      elsif (ind == 1) # Changement thème
        display_message("Choisissez votre thème.\n(Flèche gauche et droite pour changer de thème.)", 1)
        old_theme = $storage.get_box_theme($storage.current_box)
        new_theme = old_theme
        b = true
        while(b)
          Graphics.update
          update
          if (Input.trigger?(:LEFT))
            new_theme == 1 ? new_theme = PFM::Storage::NB_THEMES : new_theme -= 1
            $storage.set_box_theme($storage.current_box, new_theme)
            change_box
          end
          if (Input.trigger?(:RIGHT))
            new_theme == PFM::Storage::NB_THEMES ? new_theme = 1 : new_theme += 1
            $storage.set_box_theme($storage.current_box, new_theme)
            change_box
          end
          if (Input.trigger?(:B))
            $storage.set_box_theme($storage.current_box, old_theme)
            change_box
            b = false
          end
          if (Input.trigger?(:A))
            display_message("Le nouveau thème a été enregistré.", 1)
            b = false
          end
        end
      end
    end

    def deplacement_boite(index, mode = :move, pokemon_move = nil)
      if (Input.trigger?(:UP))
        (index <= 6) ? index = 0 : index -= 6
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:LEFT))
        index -= 1
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:RIGHT))
        index += 1 if index < 30
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:DOWN))
        if (index < 25)
          index += 6
        elsif (mode == :move)
          index = 31
        end
        draw_selector(index, pokemon_move)
      end
      return index
    end

    def changer_boite(index, pokemon_move = nil)
      if (Input.trigger?(:RIGHT))
        if ($storage.current_box < ($storage.max_box - 1))
          $storage.current_box += 1
        else
          $storage.current_box = 0
        end
        change_box
      end
      if (Input.trigger?(:LEFT))
        if ($storage.current_box < 1)
          $storage.current_box = $storage.max_box - 1
        else
          $storage.current_box -= 1
        end
        change_box
      end
      if (Input.trigger?(:DOWN))
        index = 1
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:A))
        gestion_boite
      end
      return index
    end

    def deplacement_equipe(index, mode = :move, pokemon_move = nil)
      if (Input.trigger?(:LEFT))
        index -= 1 if (index > 31)
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:RIGHT))
        index += 1 if (index < 36)
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:UP))
        if (index >= 34)
          index -= 3
        elsif (mode == :move)
          arr = $storage.get_box($storage.current_box)
          i = 29
          while(i > 0)
            break if (arr[i] != nil)
            i -= 1
          end
          index = i + 1
        end
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:DOWN))
        index += 3 if (index < 34)
        draw_selector(index, pokemon_move)
      end
      return index
    end

    def sumary_pokemon(index)
      if (index >= 31) # Pokémon de l'équipe
        pkmn = $actors[index - 31]
        scene = GamePlay::Sumary.new(pkmn, @viewport.z, :view, $actors)
      else # Pokémon de la boite
        pkmn = $storage.info(index - 1)
        pbox = $storage.get_box($storage.current_box).clone
        scene = GamePlay::StorageSumary.new(pkmn, @viewport.z, :view, pbox.compact)
      end
      @viewport.visible = false
      scene.main
      @viewport.visible = true
      Graphics.transition
    end

    def release_pokemon(index)
      c = display_message("Relâcher ce Pokémon ?", 1, *["Oui", "Non"])
      return if (c == 1)
      if (index >= 31) # Pokémon de l'équipe
        pkmn = $actors[index - 31]
        $actors[index - 31] = nil
        unless check
          return $actors[index - 31] = pkmn
        end
        $actors.compact!
        draw_pokemon_team
      else # Pokémon de la boite
        pkmn = $storage.remove(index - 1)
        draw_pokemon_box
      end
      display_message("#{pkmn.given_name} a été relâché.", 1)
      display_message("Bye-bye, #{pkmn.given_name} !", 1)
      draw_info_pokemon(index)
    end

    def check
      if ($pokemon_party.pokemon_alive == 0)
        display_message("Il vous faut au moins un Pokémon en forme !", 1)
        return false
      end
      return true
    end
    
    def init_pokemon_box
      @box = SpriteStack.new(@viewport, 25, 36)
      # Fond de la boîte
      @box.push(-12, -18, nil)
      # Pokémon de la boîte
      c, l = 0, -1
      30.times do |i|
        l += 1
        if (i % 6 == 0 and i != 0)
          c += 1
          l = 0
        end
        @box.push(22 * l, 20 * c - 4, nil).zoom = 0.5
      end
    end
    
    def draw_pokemon_box
      # Fond de la boîte
      id_theme = $storage.get_box_theme($storage.current_box)
      (stack = @box.stack).first.set_bitmap("f_#{id_theme}", :pc)
      # Pokémon de la boîte
      poke_box = $storage.get_box($storage.current_box)
      30.times do |i|
        next(stack[i + 1].bitmap = nil) unless poke_box[i]
        stack[i + 1].bitmap = poke_box[i].icon
      end
    end
    
    def init_selector
      @selector = SpriteStack.new(@viewport, 0, 0, default_cache: :pc)
      @selector.push(9, 27, nil).zoom = 0.5 # Pokémon
      @selector.push(10, 20, Selector)
    end
    
    def draw_selector(index, pokemon = nil)
      @selector.stack.first.bitmap = (pokemon ? pokemon.icon : nil)
      # Coordonnées
      if (index == 0) # Boîte
        @selector.set_position(70, -20)
      elsif (index > 0 and index <= 30) # Pokémon de la boîte
        @selector.set_position(16 + ((index - 1) % 6) * 22, 0 + ((index - 1) / 6) * 20)
      elsif (index >= 31) # Pokémon de l'équipe
        if (index > 33)
          @selector.set_position(21 + 50*(index - 34), 155+14)
        else
          @selector.set_position(21 + 50*(index - 31), 123+14)
        end
      end
      draw_info_pokemon(index)
    end

    def draw_pokemon_team
      6.times do |i|
        pokemon = $actors[i]
        @party_back[i].stack.last.bitmap = (pokemon ? pokemon.icon : nil)
      end
    end
    
    def init_pokemon_info
      stack = @info_pokemon = SpriteStack.new(@viewport, 180, 28)
      stack.push(108, -2, nil, type: PokemonIconSprite)
      
      stack.add_text(0, 0, 100, 16, :given_name_upper, type: SymText).set_size(8)
      
      stack.add_text(0, 23, 50, 16, :id_text2, type: SymText).set_size(8)
      stack.add_text(63, 23, 50, 16, :level_text2, type: SymText).set_size(8)
      stack.push(124, 22, nil, type: GenderSprite).zoom = 0.5
      
      #stack.add_text(0, 35, 50, 16, "Nature").set_size(8)
      stack.add_text(16, 59, 60, 16, :nature_text, type: SymText).set_size(8)
      
      #stack.add_text(62, 35, 50, 16, "Type").set_size(8)
      stack.push(88, 62, nil, type: Type1Sprite).zoom = 0.5
      stack.push(88, 75, nil, type: Type2Sprite).zoom = 0.5
      
      #stack.add_text(0, 67, 50, 16, "Objet").set_size(8)
      stack.add_text(16, 95, 95, 16, :item_name, type: SymText).set_size(8)
      
      #stack.add_text(0, 99, 50, 16, "Attaques").set_size(8)
      @info_pokemon_skills = Array.new(4) do |i|
        stack.add_text(8, 135 + 17 * i, 100, 16, nil.to_s).set_size(8)
      end
    end
    
    def draw_info_pokemon(index)
      return @info_pokemon.visible = false if index == 0
      if (index >= 31) # Pokémon de l'équipe
        pokemon = $pokemon_party.actors[index - 31]
      else # Pokémon de la boîte
        pokemon = $storage.info(index - 1)
      end
      return @info_pokemon.visible = false if pokemon == nil
      @info_pokemon.visible = true unless @info_pokemon.visible
      @info_pokemon.data = pokemon
      skills = pokemon.skills_set
      @info_pokemon_skills.each_with_index do |text, i|
        text.text = (skills[i] ? skills[i].name_upper : nil.to_s)
      end
    end
    
    def draw_init
      change_box
      draw_pokemon_team
    end

    def dispose
      @message_window.dispose
      @viewport.dispose
    end
  end
end