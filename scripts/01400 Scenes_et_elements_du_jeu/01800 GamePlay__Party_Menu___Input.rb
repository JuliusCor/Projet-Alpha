module GamePlay
  class Party_Menu < Base

    # Array of actions to do according to the pressed button
    Actions = %i[action_A action_X action_Y action_B]
    
    def selector_black
      @selector.src_rect.set(0,0,10,14)
    end
    
    def selector_select
      @selector.src_rect.set(10,0,10,14)
    end
    
    def selector_red
      @selector.src_rect.set(20,0,10,14)
    end
    
    def selector2_add
      @selector2.visible = true
      @selector2.x = @selector.x
      @selector2.y = @selector.y
      @selector2.src_rect.set(10,0,10,14)
    end
    
    def selector2_del
      @selector2.visible = false
    end
    # Action triggered when A is pressed
    def action_A
      #return $game_system.se_play($data_system.buzzer_se) if @page_id
      #$game_system.se_play($data_system.decision_se)
      case @mode
      when :menu
        action_A_menu
      else
        $game_system.se_play($data_system.decision_se)
        show_choice
      end
    end

    # Action when A is pressed and the mode is menu
    def action_A_menu
      case @intern_mode
      when :choose_move_pokemon
        action_move_current_pokemon
      when :choose_move_item
        return $game_system.se_play($data_system.buzzer_se) if @team_buttons[@index].data.item_holding.zero?
        @team_buttons[@move = @index].selected = true
        @intern_mode = :move_item
      when :move_pokemon
        process_switch
        selector2_del
      when :move_item
        process_item_switch
      else
        $game_system.se_play($data_system.decision_se)
        return show_choice
      end
      $game_system.se_play($data_system.decision_se)
    end

    # Action triggered when B is pressed
    def action_B
      return if no_leave_B
      $game_system.se_play($data_system.decision_se)
      # Cancel choice attempt
      return @choice_object.cancel if @choice_object
      # Returning to normal mode
      if @intern_mode != :normal
        hide_item_name
        @team_buttons[@move].selected = false if @move != -1
        @move = -1
        return @intern_mode = :normal
      end
      @running = false
    end
    
    # Function that detect no_leave and forbit the B action to process
    # @return [Boolean] true = no leave, false = process normally
    def no_leave_B
      if @no_leave
        return false if @choice_object
        return false if @intern_mode != :normal
        $game_system.se_play($data_system.buzzer_se)
        return true
      end
      return false
    end

    # Update the mouse interaction with the ctrl buttons
    def update_mouse_ctrl
    end

    # Update the movement of the Cursor
    def update_selector_move
      party_size = @team_buttons.size
      if Input.trigger?(:DOWN)
        if(@index == 6)
          @index = 0
        elsif(@index == party_size - 1)
          @index = 6
        else
          @index += 1
        end
        update_selector_coordinates
      elsif Input.trigger?(:UP)
        if(@index == 6)
          @index = party_size - 1
        else
          @index -= 1
        end
        @index = 6 if(@index < 0)
        update_selector_coordinates
      else index_changed(:@index, :U, :I, party_size - 1)
        update_selector_coordinates
      end
    end

    # Update the movement of the selector with the mouse
    def update_mouse_selector_move
    end

    # Update the selector coordinates
    def update_selector_coordinates(*)
      #btn = @team_buttons[@index]
      @selector.set_position(4, 34 * @index + 10)
      @selector.set_position(4, 34 * @index + 4) if(@index == 6)
    end

    # Select the current pokemon to move with an other pokemon
    def action_move_current_pokemon
      selector_black
      selector2_add
      return if @party.size <= 1
      @team_buttons[@move = @index].selected = true
      @intern_mode = :move_pokemon
    end
    
  end
end