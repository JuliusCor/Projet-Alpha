#noyard
module GamePlay
  class StorageBoxItems < Base
    include Text::Util
    include UI
    def initialize
      super()
      $game_switches[147] = $game_switches[26] = false
      @viewport = select_view(view(:main, 1000))
      init_text(0, @viewport)
      @background = Sprite.new(@viewport).set_bitmap("box_old", :pc)
      @orange_sprite = Sprite.new(@viewport)
        .set_bitmap("orange_sprite", :pc)
        .set_position(16, 64)
      @selector = Sprite.new(@viewport).set_bitmap("selector", :pc)
      @selector.set_position(140,58)
      @index = 0
      @index_sub = 0
      @offset = 0
      update_box
      init_name_list
      update_name_list(@offset)
      init_pokemon_info
      init_sprite_shader
      update_info_pokemon
      init_window
      @running = true
    end

    def update
      #> Haut
      if (Input.trigger?(:UP))
        if(@index_sub != 0)
          @index_sub -= 1 
        elsif(@index_sub == 0 and @index != 0)
          @offset -= 1
          @retour.visible = false
        end
        if(@index != 0)
          @index -= 1
        end
        update_name_list(@offset)
        update_info_pokemon
      end
      #> Bas
      if (Input.trigger?(:DOWN))
        if(@index_sub != 4)
          if(@index_sub >= @current_box_list.size)
            @index_sub = @current_box_list.size
          else
            @index_sub += 1
          end
        elsif(@index_sub == 4 and @index != @current_box_list.size)
          @offset += 1
        end
        if(@index != @current_box_list.size)
          @index += 1
        end
        update_name_list(@offset)
        update_info_pokemon
      end
      #> Droite
      if (Input.trigger?(:RIGHT))
        reset_index
        if ($storage.current_box < ($storage.max_box - 1))
          $storage.current_box += 1
        else
          $storage.current_box = 0
        end
        update_box
        update_name_list(@offset)
        update_info_pokemon
      end
      #> Gauche
      if (Input.trigger?(:LEFT))
        reset_index
        if ($storage.current_box < 1)
          $storage.current_box = $storage.max_box - 1
        else
          $storage.current_box -= 1
        end
        update_box
        update_name_list(@offset)
        update_info_pokemon
      end
      #> Annulé
      if (Input.trigger?(:B))
        @running = false
      end
      #> Action
      if (Input.trigger?(:A))
        if(@index == @current_box_list.size)
          $game_system.se_play($data_system.decision_se)
          @running = false
        else
          $game_system.se_play($data_system.decision_se)
          @selector.visible = false
          menu_choice
        end
      end
      @selector.set_position(140,58 + 32*@index_sub)
      @message_window.update
    end

    def init_name_list #> Creation des noms de pokémon, de la boite et de texte RETOUR
      @name_list = Array.new(5) { |i| add_text(144, 64 + 32*i, 100, 16, :given_name_upper11, type: SymText) }
      @boite = add_text(180,20,160,16, "Boite " + $storage.current_box.to_s)
      @retour = add_text(144, 64 + 32*@index_sub, 100, 16, "RETOUR")
      @retour.visible = false
      @pokemon_counter = add_text(0-57,34,160,16,"", 2)
      @pokemon_counter.text = @current_box_list.size.to_s + "/30"
    end

    def update_box #> Changement de Box
      @current_box_list = $storage.get_box($storage.current_box).select { |element| element }
    end

    def update_name_list(offset_index) #> Update de la liste des nom
      update_box
      pokemon_list = @current_box_list
      5.times do |i|
        @name_list[i].data = pokemon_list[offset_index + i]
      end
      @boite.text = "Boite " + $storage.current_box.to_s
      if(@index == @current_box_list.size and @current_box_list.size >= 5)
        @retour.y = 190
        @retour.visible = true
      end
      if(@offset == 0 and @current_box_list.size < 5)
        @retour.y = 62 + 32*@current_box_list.size
        @retour.visible = true
      end
      @pokemon_counter.text = @current_box_list.size.to_s + "/30"
    end

    def reset_index #> Reset des variables lors du changement de boite
      @retour.visible = false
      @index = 0
      @index_sub = 0
      @offset = 0
    end

    def init_window
      @message_window = Window_Message.new(@viewport)
      @message_window.height = 48
      @message_window.width = 320
    end

    def init_sprite_shader
      pokemon = $storage.info(@index)
      @sprite_pokemon = ShaderedSprite.new(@viewport)
      @sprite_pokemon.bitmap = pokemon.battler_face if(@current_box_list.size >= 1)
      @sprite_pokemon.set_position(16, 64)
      @sprite_pokemon.shader = Shader.new(Shader.load_to_string('PC_SpriteToOrange'))
    end

    def init_pokemon_info
      stack = @info_pokemon = SpriteStack.new(@viewport)
      @name = stack.add_text(16, 224, 100, 16, :given_name_upper, type: SymText)
      @level_n = stack.push(18, 196, "team/level_n")
      @level_text = stack.add_text(32, 192, 50, 16, :level_text, type: SymText)
      @gender = stack.push(80, 190, nil, type: GenderSprite)
      stack.push(112, 192, "team/Item", type: HoldSprite)
    end

    def update_info_pokemon
      pokemon = $storage.info(@index)
      return @sprite_pokemon.visible = @info_pokemon.visible = false if pokemon == nil
      @info_pokemon.data = pokemon
      @sprite_pokemon.bitmap = pokemon.battler_face
      @sprite_pokemon.visible = true
      return @info_pokemon.visible = false if(pokemon.egg?)
      if(pokemon.level >= 100)
        @level_n.visible = false
        @level_text.x = 16
      else
        @level_n.visible = true
        @level_text.x = 32
      end
    end

    def _box_window(*args)
      window=Window_Choice.new(150,args)
      max = args.size
      window.z=@viewport.z+1
      window.height = 32+32*max
      height = 32+32*max
      window.width = 176
      window.x = 144
      window.y = 288-height-64
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

    def menu_choice
      pokemon = $storage.info(@index)
      if(pokemon.egg?)
        menu_choice_egg
      elsif(@current_box_list[@index].item_holding <= 0 and !pokemon.egg?)
        menu_choice3
      else
        menu_choice4
      end
    end

    def menu_choice3
      pokemon = $storage.info(@index)
      choix=_box_window("DEPOSER", "STATS", "RETOUR")
      if(choix==0) #> Deposer
        item2 = -1
        pokemon = @current_box_list[@index]
        if item2 == -1
          @__result_process = proc { |scene| item2 = scene.return_data }
          call_scene(Bag, :hold)
        end
        return menu_choice3 if item2 == -1
        item1 = pokemon.item_holding
        pokemon.item_holding = item2 if(item2 != -1)
        $bag.add_item(item1, 1)
        $bag.remove_item(item2, 1)
      elsif(choix==1) #> Stats
        $game_system.se_play($data_system.decision_se)
        pbox = $storage.get_box($storage.current_box).clone
        scene = GamePlay::StorageSumary.new(pokemon, @viewport.z, :view, pbox.compact)
        @viewport.visible = false
        scene.main
        @viewport.visible = true
        Graphics.transition
      elsif(choix==2) #> Retour
        $game_system.se_play($data_system.cancel_se)
      end
      @selector.visible = true
      update_name_list(@offset)
      update_info_pokemon
    end

    def menu_choice4
      pokemon = $storage.info(@index)
      choix=_box_window("RETIRER", "DEPOSER", "STATS", "RETOUR")
      if(choix==0) #> Retirer
        pokemon = @current_box_list[@index]
        item = pokemon.item_holding
        $bag.add_item(item, 1)
        pokemon.item_holding = 0
      elsif(choix==1) #> Deposer
        item2 = -1
        pokemon = @current_box_list[@index]
        if item2 == -1
          @__result_process = proc { |scene| item2 = scene.return_data }
          call_scene(Bag, :hold)
        end
        return menu_choice4 if item2 == -1
        item1 = pokemon.item_holding
        pokemon.item_holding = item2 if(item2 != -1)
        $bag.add_item(item1, 1)
        $bag.remove_item(item2, 1)
      elsif(choix==2) #> Stats
        $game_system.se_play($data_system.decision_se)
        pbox = $storage.get_box($storage.current_box).clone
        scene = GamePlay::StorageSumary.new(pokemon, @viewport.z, :view, pbox.compact)
        @viewport.visible = false
        scene.main
        @viewport.visible = true
        Graphics.transition
      elsif(choix==3) #> Retour
        $game_system.se_play($data_system.cancel_se)
      end
      @selector.visible = true
      update_name_list(@offset)
      update_info_pokemon
    end

    def menu_choice_egg
      pokemon = $storage.info(@index)
      choix=_box_window("STATS", "RETOUR")
      if(choix==0) #> Stats
        $game_system.se_play($data_system.decision_se)
        pbox = $storage.get_box($storage.current_box).clone
        scene = GamePlay::StorageSumary.new(pokemon, @viewport.z, :view, pbox.compact)
        @viewport.visible = false
        scene.main
        @viewport.visible = true
        Graphics.transition
      elsif(choix==1) #> Retour
        $game_system.se_play($data_system.cancel_se)
      end
      @selector.visible = true
      update_name_list(@offset)
      update_info_pokemon
    end

    def dispose
      $game_switches[147] = $game_switches[26] = true
      $game_system.se_play($data_system.cancel_se)
      @viewport.dispose
    end

  end
end