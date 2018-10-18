#noyard
module GamePlay
  class Hours < Base
    Hours = ["Hours","Hours_min"]
    Background = "Hours_Background"
    include Text::Util
    include UI
    def initialize
      super
      @viewport = Viewport.create(:main, 1000)
      init_text(0, @viewport)
      #> Descriptions heures
      @background = Sprite.new(@viewport)
      @background.bitmap=RPG::Cache.interface(Background)
      #> Cadres heures
      @cadre = Sprite.new(@viewport)
      if($game_switches[146] == false)
        @cadre.bitmap=RPG::Cache.interface(Hours[0])
      else
        @cadre.bitmap=RPG::Cache.interface(Hours[1])
      end
      #> Textes
      if($game_switches[146] == false)
        @Hours_text = add_text(160,144,136,16, "NUIT")
        @Hours_num = add_text(240,144,136,16, $game_variables[10].to_s)
        @Hours_post_text = add_text(274,144,136,16, "h")
      else
        @Hours_num = add_text(192,144,136,16, $game_variables[11].to_s)
        @Hours_post_text = add_text(224,144,136,16, "min.")
      end
      #>Variables
      @index = $game_variables[10]
      transi
    end
    
    def update
      if(Input.trigger?(:A))
        $game_variables[10] = @index if($game_switches[146] == false)
        $game_variables[11] = @index if($game_switches[146] == true)
        @running = false
      end
      if(Input.repeat?(:UP))
        @index += 1
        @index = 0 if(@index >= 24 and $game_switches[146] == false)
        @index = 0 if(@index >= 60 and $game_switches[146] == true)
        transi
      end
      if(Input.repeat?(:DOWN))
        @index -= 1
        @index = 23 if(@index <= 0 and $game_switches[146] == false)
        @index = 59 if(@index < 0 and $game_switches[146] == true)
        transi
      end
    end
    
    def transi
      draw_hours if($game_switches[146] == false)
      draw_minutes if($game_switches[146] == true)
    end
    
    def draw_hours
      if(@index >= 18 or @index <= 3)
        @Hours_text.text = "NUIT"
        @Hours_num.x = 240
        @Hours_post_text.x = 274
      elsif(@index <= 9)
        @Hours_text.text = "MATIN"
        @Hours_num.x = 256
        @Hours_post_text.x = 290
      else
        @Hours_text.text = "JOUR"
        @Hours_num.x = 240
        @Hours_post_text.x = 274
      end
      if(@index - 12 >= 10 or @index == 10 or @index == 11 or @index == 12)
        @Hours_post_text.x = 290
      end
      if(@index >= 13)
        @Hours_num.text = (@index - 12).to_s
      else
        @Hours_num.text = @index.to_s
      end
    end
    
    def draw_minutes
      if(@index >= 10)
        @Hours_post_text.x = 240
      else
        @Hours_post_text.x = 224
      end
      @Hours_num.text = @index.to_s
    end
    
    #> Fin de la scene
    def dispose
      super
      @viewport.dispose
    end
    
  end
end