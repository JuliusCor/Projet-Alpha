module PFM
  class Pokemon
    attr_accessor :trainer_name_upper
    #Majuscule pour le surnom des pokémon
    def initialize(id, level, force_shiny = false, no_shiny = false, form = -1)
      @trainer_name_upper = $trainer.name.upcase
      #>Informations utiles à la génération du code
      @captured_with = 4
      @captured_in = $env.master_zone | Flag_40
      @captured_at = Time.new.to_i
      @captured_level = level
      @trainer_id = $trainer.id
      @trainer_name = $trainer.name
      #génération du code
      code_generation(force_shiny, no_shiny)
      #>Génération du genre
      if($game_data_pokemon[id][0].female_rate>0)
        @gender=(rand(100)<$game_data_pokemon[id][0].female_rate ? 2 : 1)
      else
        @gender=0
      end
      
      @id = id
      form = _form_generation(id, form)
      data = $game_data_pokemon[id][form]
      form = 0 unless data
      data = $game_data_pokemon[id][form]
      @id=id
      @level=level.to_i
      @step_remaining=0
      @given_name = nil
      @ev_hp=0
      @ev_atk=0
      @ev_dfe=0
      @ev_spd=0
      @ev_ats=0
      @ev_dfs=0
      @form=form
      @status=0
      @status_count=0
      @battle_stage=Array.new(7,0)
      @last_skill=0
      @position=0
      @battle_effect=nil
      ability=data.abilities
      #>Récupération du talent (caché ou non)
      ability_chance=rand(100)
      if(ability_chance<2)
        @ability=ability[2].to_i
      elsif(ability_chance<50)
        @ability=ability[1].to_i
      else
        @ability=ability[0].to_i
      end
      @ability_current=@ability
      @nature=@code%(GameData::Natures.size)
      @loyalty=data.base_loyalty
      @exp=exp_list[@level].to_i
      #>Génération des IV
      iv_base=((Shiny_IV && @shiny) ? 15 : 0)
      iv_rand=((Shiny_IV && @shiny) ? 17 : 32)
      @iv_hp=rand(iv_rand)+iv_base
      @iv_atk=rand(iv_rand)+iv_base
      @iv_dfe=rand(iv_rand)+iv_base
      @iv_spd=rand(iv_rand)+iv_base
      @iv_ats=rand(iv_rand)+iv_base
      @iv_dfs=rand(iv_rand)+iv_base
      #>Génération du Skillset
      @skill_learnt = []
      @skills_set=Array.new
      (data.move_set.size-2).step(0,-2) do |i|
        if(data.move_set[i]<=@level)
          learn_skill(data.move_set[i+1]) unless skill_learnt?(data.move_set[i+1])
          # @skills_set<<Skill.new(data.move_set[i+1]) unless skill_learnt?(data.move_set[i+1])
          break if @skills_set.size>=4
        end
      end
      @skills_set.reverse!
      @hp=self.max_hp
      #>Selection de l'objet aléatoire
      parr=[]
      iarr=[]
      _per=0
      _items=data.items
      (_items.size/2).times do |i|
        iarr<<_items[i*2]
        _per+=_items[i*2+1]
        parr<<_per
      end
      if(parr.size>0)
        _rand=rand(100)
        parr.size.times do |i|
          if(_rand<parr[i])
            @item_holding=iarr[i]
            break
          end
        end
      end
      @item_holding=@item_holding.to_i
      parr=nil
      iarr=nil
      @battle_turns=0
      @ability_used=false
      @sub_id=nil
      @hp_rate = 1
      @exp_rate = 0
      @mega_evolved = false
    end
    
    def given_name_upper
      return @given_name.upcase if @given_name
      return self.name_upper
    end
    
    def given_name_upper11
    result = given_name_upper
    if result.size > 10
      return result[0, 9] + "..."
    end
      return result
    end
    # Return the nature data of the Pokemon
    # @return [Array<Integer>] [text_id, atk%, dfe%, spd%, ats%, dfs%]
    def nature_text_upper
      return _get(8, @nature).upcase
    end
    
    # Return the name of the current ability of the Pokemon
    # @return [String]
    def ability_name_upper
      return GameData::Abilities.name(self.ability).upcase
    end
    
    #Ajoute un level au pokemon pour le Summary::A
    def next_level_string
      level = @level + 1
      return level >= GameData::MAX_LEVEL ? GameData::MAX_LEVEL.to_s : level.to_s
    end
    
    # Return the text of the Pokemon ID with N°
    # @return [String]
    def id_text2
      sprintf("No.%03d", $pokedex.national? ? @id : ::GameData::Pokemon.id_bis(@id))
    end
    
    # Returns the HP text (to_pokemon_number)
    # @return [String]
    def hp_pokemon_number
      "#@hp/#{self.max_hp}"#.to_pokemon_number
    end
    
    # Returns the HP text (to_pokemon_number)
    # @return [String]
    def hp_pokemon_max
      "#{self.max_hp}"#.to_pokemon_number
    end
    
    # Returns the HP text (to_pokemon_number)
    # @return [String]
    def hp_pokemon_given
      "#@hp"#.to_pokemon_number
    end
    
    # Return the level text (to_pokemon_number)
    # @return [String]
    def level_pokemon_string
      @level.to_s
    end
    
    # Return the level text (to_pokemon_number)
    # @return [String]
    def level_pokemon_none
      @level
    end
    
  end
end