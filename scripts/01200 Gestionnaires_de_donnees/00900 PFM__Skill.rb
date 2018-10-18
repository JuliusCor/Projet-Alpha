module PFM
  class Skill
    #Majuscule pour les attaques
    def name_upper
      return GameData::Text.get(6,@id).upcase#$game_data_skill[@id].name
    end
    #PP Max
    def pp_text_max
      "#@ppmax"
    end
    #PP Current
    def pp_text_current
      "#@pp"
    end
  end
end