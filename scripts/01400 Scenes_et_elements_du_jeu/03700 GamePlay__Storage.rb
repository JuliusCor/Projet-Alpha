#noyard
module GamePlay
  class Storage < Base
    Start = ["PC DE LEO", "PC DE CHEN", "DECONNEXION"]
    # £ = signe pkmn
    Storage = ["RETIRER £", "STOCKER £", "DEPLACER £",
              "RANGER OBJETS £", "SALUT !"]
    def initialize(mode = nil)
      @viewport = Viewport.create(:main, 10000)
      super()
      $game_switches[26] = true
      @mode = mode 
      @running = true
    end

    def main_begin
      if @__last_scene.class == ::Scene_Map
        @__display_message_proc = proc { @__last_scene.sprite_set_update }
      end
      start_pc
      super
    end

    def main_end
      super
      Graphics.transition
    end

    def update
      @__display_message_proc.call if @__display_message_proc
      super
    end

    def start_pc
      if (@mode == :trade)
        # traitement spécifique si échange   
      else
        Audio.se_play("Audio/SE/2G_Computer_Open.wav")
        display_message("#{$pokemon_party.trainer.name} allume le PC.")
        choisir_pc
      end
    end

    def choisir_pc
      $game_switches[147] = false
      c = display_message("A quel PC souhaitez vous accéder ?", 1, *Start)
      case c
      when 0 # PC de Stockage
        $game_switches[147] = true
        storage_pc
      when 1 # PC du Professeur
        professor_pc
      when 2 # Déconnexion 
        display_message(". . . \nDéconnexion . . .", 1)
        Audio.se_play("Audio/SE/2G_Computer_Close.wav")
        @running = false
      end  
    end

    def storage_pc
      c = display_message("Que faire?", 1, *Storage)
      while $game_temp.message_window_showing
        @message_window.update
        Graphics.update
      end
      case c
      when 0 # Retirer Pokémon
        stop
        call_scene(StorageBoxDel)   
      when 1 # Stocker Pokémon
        stop
        call_scene(StorageBoxAdd)
      when 2 # Deplacer Pokémon 
        stop
        call_scene(StorageBoxMove)    
      when 3 # Réarranger des objets 
        stop
        call_scene(StorageBoxItems) 
      when 4 # Quitter
        choisir_pc
      end
      storage_pc if (c != 4)
    end

    def professor_pc
      $game_temp.common_event_id = 52
      @running = false
    end
    
    def _party_window(*args)
      window=Window_Choice_Party.new(105,args)
      window.z=@viewport.z+1
      window.x=0
      window.y=0
      window.height = 256
      window.width = 160
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
    
    def stop
      $game_switches[26] = false
    end
    
    def dispose
      $game_switches[147] = $game_switches[26] = false
      @message_window.dispose
      @viewport.dispose 
    end
  end
end
