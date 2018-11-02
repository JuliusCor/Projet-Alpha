#noyard
module GamePlay
  class TCard < Base
    TC_Girl = "TCard/Trainer_Card_F"
    TC_Boy = "TCard/Trainer_Card_M"
    include Text::Util
    include UI
    def initialize(page_id = false)
      super()
      @viewport = select_view(view(:main, 1000))
      init_text(0, @viewport)
      #> Background
      @background = Sprite.new(@viewport)
      if($trainer.playing_girl)
        @background.bitmap=RPG::Cache.interface(TC_Girl)
      else
        @background.bitmap=RPG::Cache.interface(TC_Boy)
      end
      draw_text
      @counter = 0
      @seen_got = TrainerGot.new(@viewport)
      @seen_got.set_position(209,155) #> Nombres pkm
    end
    
    def update
      @counter += 1
      if(@counter > 30)
        switch_sprite
        @counter = 0
      end
      if Input.trigger?(:A)
        call_scene(TBadge)
      end
      if Input.trigger?(:B)
        @running = false
      end
      if (Input.trigger?(:RIGHT))
        call_scene(TBadge)
      end
    end
    
    def draw_text
      start_time = (Time.new-(Time.new.to_i-$trainer.start_time))
      add_text(0,8,136,16, $trainer.name) #> Nom du joueur
      add_text(48,40,136,16, sprintf("%05d",$trainer.id%100000)) #> Id joueur
      add_text(0,72,136,16, _get(34,7)) #> ARG.
      add_text(52,72,136,16, _parse(34,8, NUM7R => $pokemon_party.money.to_s), 2) #> Argent
      add_text(0,136,224,16, "POKéDEX") #> POKEDEX
      add_text(0,168,224,16, "DUREE JEU") #> DUREE JEU
      time = $trainer.update_play_time
      hours = time/3600
      minutes = (time-3600*hours)/60
      @txt_dot = add_text(32,168,224,16, sprintf("%02d %s %02d", hours, _get(25,6), minutes), 2)
      @txt_ndot1 = add_text(32,168,224,16, sprintf("%02d", minutes), 2)
      @txt_ndot2 = add_text(-8,168,202,16, sprintf("%02d", hours), 2)
      @texts.each { |text| text.set_position(text.x + 32, text.y + 24) }
      switch_sprite
    end
    
    def switch_sprite
      state = @txt_ndot1.visible
      @txt_ndot1.visible =@txt_ndot2.visible = !state
      @txt_dot.visible = state
    end
    
  end
end