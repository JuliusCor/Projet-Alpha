module Yuki
  # Module that manage the growth of berries.
  # @author Nuri Yuri
  # 
  # The berry informations are stored in $pokemon_party.berries, a 2D Array of berry information
  #   $pokemon_party.berries[map_id][event_id] = [berry_id, stage, timer, stage_time, water_timer, water_time, water_counter, info_engrais]
  module Berries
    # The base name of berry character
    PlantedChar = "GBC_BAIE_P"
    module_function
    # Update of the berry event graphics
    # @param event_id [Integer] id of the event where the berry tree is shown
    # @param data [Array] berry data
    def update_event(event_id, data)
      return unless event = $game_map.events[event_id]
      if(data[0] == 0)
        return event.opacity = 0
      end
      stage = data[1]
      event.character_name = stage == 0 ? PlantedChar : "GBC_BAIE_#{data[0]}"
      event.direction = (stage == 1 ? 2 : (stage == 2 ? 4 : (stage == 3 ? 6 : 8)))
      event.opacity = 255
    end
  end
end