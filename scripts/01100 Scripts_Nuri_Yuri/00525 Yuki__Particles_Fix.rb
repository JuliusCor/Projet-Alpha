# Make particles work correctly
module Yuki
  class Particle_Object
    alias psdk_initialize initialize
    # See PSDK doc
    def initialize(character, data, on_tp = false)
      psdk_initialize(character, data, on_tp)
      @zoom = 1
      @add_z = 2
    end
    
    alias psdk_exectute_action exectute_action
    
    # Execute an animation instruction
    # @param action [Hash] the animation instruction
    def exectute_action(action)
      psdk_exectute_action(action)
      if action[:chara] || action[:rect]
        @ox *= 2
        @ox += 8
        @oy *= 2
      end
    end

    # Update the position of the particle sprite
    def update_sprite_position
      case @position_type
      when :center_pos
        @sprite.x=((@x*128 - $game_map.display_x + 3) / 4 + 32)/@zoom
        @sprite.y=((@y*128 - $game_map.display_y + 3) / 4 + 32)
        @sprite.z=@character.screen_z(0)/@zoom
        if @sprite.y>=@character.screen_y
          @sprite.z=(@character.screen_z(0)+@add_z)#/@zoom
        else
          @sprite.z=(@character.screen_z(0)-1)#/@zoom
        end
        @sprite.y/=@zoom
        @sprite.ox=@ox * @zoom
        @sprite.oy=@oy * @zoom + @oy_off#(@oy+@oy_off)*@zoom
      when :character_pos
        @sprite.x=@character.screen_x/@zoom
        @sprite.y=@character.screen_y/@zoom
        @sprite.z=(@character.screen_z(0)+@add_z)/@zoom
        @sprite.ox=@ox
        @sprite.oy=@oy+@oy_off
      end
    end
  end
end
