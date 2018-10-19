# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri, Aerun
# Date: 2014
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Interpréteur des actions des attaques
module BattleEngine
  module BE_Interpreter
    module_function

    def efficiency_sound(mod)
      return if @ignore or mod == 0
      if mod == 1
        Audio.se_play("Audio/SE/2G_Hit.wav")
      elsif mod > 1
        Audio.se_play("Audio/SE/2G_Hit_Plus.wav")
      else
        Audio.se_play("Audio/SE/2G_Hit_Low.wav")
      end
    end
	
  end
end