#Reprise du systeme d'endurance d'Eurons: https://pokemonworkshop.fr/forum/index.php?topic=4507.msg116536
#Leikt, Eurons, Yuri sont a citer dans vos crédits pour l'utilisation de ce système.
#Correction lié à un soucis en cbt par Yuri
module PFM
    class Pokemon_Party
    # <FR> Modifier le numéro après '=' pour définir le maximum d'endurance
    # <EN> Modify the number after '=' to define the pas's maximum value
    PAS_MAX = 10
        attr_accessor :pas_steps
        alias pas_initialize initialize
        def initialize(battle=false, starting_language = "fr")
            pas_initialize(battle, starting_language)
            @pas_steps = 0
        end
        alias pas_increase_steps increase_steps
        def increase_steps
            if($game_switches[153] == true)
              pas_change(1)
            end
            return pas_increase_steps
        end
   
        def pas_reset
            @pas_steps = 0
        end
   
        def pas_change(amount, maximum = PAS_MAX)
            if amount > 0
                @pas_steps = [@pas_steps + amount, maximum].min
            else
                @pas_steps = [@pas_steps + amount, 0].max
            end
        end
    end
end
