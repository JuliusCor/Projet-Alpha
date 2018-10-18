#noyard
module GamePlay
  class TBadge < Base
    TC_Girl = "Trainer_Card_F_Badge"
    TC_Boy = "Trainer_Card_M_Badge"
    Badge = "Trainer_Badge"
    Animation = "Trainer_Badge_Anim"
    Champions = "Trainer_Champions"
    include Text::Util
    include UI
    def initialize
      super
      @viewport = Viewport.create(:main, 1000)
      init_text(0, @viewport)
      #> Background
      @background_badge = Sprite.new(@viewport)
      if($trainer.playing_girl)
        @background_badge.bitmap=RPG::Cache.interface(TC_Girl)
      else
        @background_badge.bitmap=RPG::Cache.interface(TC_Boy)
      end
      #> Counter animations badge
      @counter = 0
      #> Frame d'animation du badge
      @frame = 0
      #> Icones champions
      @champ1 = Sprite.new(@viewport)
      @champ1.bitmap=RPG::Cache.interface(Champions)
      @champ2 = Sprite.new(@viewport)
      @champ2.bitmap=RPG::Cache.interface(Champions)
      @champ3 = Sprite.new(@viewport)
      @champ3.bitmap=RPG::Cache.interface(Champions)
      @champ4 = Sprite.new(@viewport)
      @champ4.bitmap=RPG::Cache.interface(Champions)
      @champ5 = Sprite.new(@viewport)
      @champ5.bitmap=RPG::Cache.interface(Champions)
      @champ6 = Sprite.new(@viewport)
      @champ6.bitmap=RPG::Cache.interface(Champions)
      @champ7 = Sprite.new(@viewport)
      @champ7.bitmap=RPG::Cache.interface(Champions)
      @champ8 = Sprite.new(@viewport)
      @champ8.bitmap=RPG::Cache.interface(Champions)
      #> Icones Badge
      @badge1 = Sprite.new(@viewport)
      @badge1.bitmap=RPG::Cache.interface(Badge)
      @badge2 = Sprite.new(@viewport)
      @badge2.bitmap=RPG::Cache.interface(Badge)
      @badge3 = Sprite.new(@viewport)
      @badge3.bitmap=RPG::Cache.interface(Badge)
      @badge4 = Sprite.new(@viewport)
      @badge4.bitmap=RPG::Cache.interface(Badge)
      @badge5 = Sprite.new(@viewport)
      @badge5.bitmap=RPG::Cache.interface(Badge)
      @badge6 = Sprite.new(@viewport)
      @badge6.bitmap=RPG::Cache.interface(Badge)
      @badge7 = Sprite.new(@viewport)
      @badge7.bitmap=RPG::Cache.interface(Badge)
      @badge8 = Sprite.new(@viewport)
      @badge8.bitmap=RPG::Cache.interface(Badge)
      @badge1.visible = @badge2.visible = @badge3.visible = @badge4.visible = false
      @badge5.visible = @badge6.visible = @badge7.visible = @badge8.visible = false
      #> Icones Frame
      @frame1 = Sprite.new(@viewport)
      @frame1.bitmap=RPG::Cache.interface(Animation)
      @frame2 = Sprite.new(@viewport)
      @frame2.bitmap=RPG::Cache.interface(Animation)
      @frame3 = Sprite.new(@viewport)
      @frame3.bitmap=RPG::Cache.interface(Animation)
      @frame4 = Sprite.new(@viewport)
      @frame4.bitmap=RPG::Cache.interface(Animation)
      @frame5 = Sprite.new(@viewport)
      @frame5.bitmap=RPG::Cache.interface(Animation)
      @frame6 = Sprite.new(@viewport)
      @frame6.bitmap=RPG::Cache.interface(Animation)
      @frame7 = Sprite.new(@viewport)
      @frame7.bitmap=RPG::Cache.interface(Animation)
      @frame8 = Sprite.new(@viewport)
      @frame8.bitmap=RPG::Cache.interface(Animation)
      @frame1.visible = @frame2.visible = @frame3.visible = @frame4.visible = false
      @frame5.visible = @frame6.visible = @frame7.visible = @frame8.visible = false
      #>Dessins de la scene
      draw_scene
    end
    
    def update
      @counter +=1
      if(@counter == 8)
        @counter = 0
        @frame += 1
        @frame = 0 if(@frame > 3)
        draw_frame
      end
      if Input.trigger?(:A)
        @running = false
      end
      if Input.trigger?(:B)
        #@running = false
        return_to_scene(Menu)
      end
      if (Input.trigger?(:LEFT))
        #call_scene(TCard)
        @running = false
      end
    end
    
    def draw_scene
      add_text(32,32,136,16, $trainer.name) #> Nom du joueur
      add_text(48+32,40+24,136,16, sprintf("%05d",$trainer.id%100000)) #> Id joueur
      add_text(0+32,72+24,136,16, _get(34,7)) #> ARG.
      add_text(52+32,72+24,136,16, _parse(34,8, NUM7R => $pokemon_party.money.to_s), 2) #> Argent
      #> Variable des espacements entre les icones
      @space_x = 64
      @space_y = 48
      #> Icones champions
      # Haut
      @champ1.src_rect.set(46*0,0,46,32)
      @champ1.set_position(50+@space_x*0,176)
      @champ2.src_rect.set(46*1,0,46,32)
      @champ2.set_position(50+@space_x*1,176)
      @champ3.src_rect.set(46*2,0,46,32)
      @champ3.set_position(50+@space_x*2,176)
      @champ4.src_rect.set(46*3,0,46,32)
      @champ4.set_position(50+@space_x*3,176)
      # Bas
      @champ5.src_rect.set(46*4,0,46,32)
      @champ5.set_position(50+@space_x*0,176+@space_y)
      @champ6.src_rect.set(46*5,0,46,32)
      @champ6.set_position(50+@space_x*1,176+@space_y)
      @champ7.src_rect.set(46*6,0,46,32)
      @champ7.set_position(50+@space_x*2,176+@space_y)
      @champ8.src_rect.set(46*7,0,46,32)
      @champ8.set_position(50+@space_x*3,176+@space_y)
      #> Icones Badge
      # Haut
      @badge1.src_rect.set(32*0,0,32,32)
      @badge1.set_position(32+@space_x*0,176)
      @badge2.src_rect.set(32*1,0,32,32)
      @badge2.set_position(32+@space_x*1,176)
      @badge3.src_rect.set(32*2,0,32,32)
      @badge3.set_position(32+@space_x*2,176)
      @badge4.src_rect.set(32*3,0,32,32)
      @badge4.set_position(32+@space_x*3,176)
      # Bas
      @badge5.src_rect.set(32*4,0,32,32)
      @badge5.set_position(32+@space_x*0,176+@space_y)
      @badge6.src_rect.set(32*5,0,32,32)
      @badge6.set_position(32+@space_x*1,176+@space_y)
      @badge7.src_rect.set(32*6,0,32,32)
      @badge7.set_position(32+@space_x*2,176+@space_y)
      @badge8.src_rect.set(32*7,0,32,32)
      @badge8.set_position(32+@space_x*3,176+@space_y)
      #> Icones Frame
      # Haut
      @frame1.set_position(32+@space_x*0,176)
      @frame2.set_position(32+@space_x*1,176)
      @frame3.set_position(32+@space_x*2,176)
      @frame4.set_position(32+@space_x*3,176)
      # Bas
      @frame5.set_position(32+@space_x*0,176+@space_y)
      @frame6.set_position(32+@space_x*1,176+@space_y)
      @frame7.set_position(32+@space_x*2,176+@space_y)
      @frame8.set_position(32+@space_x*3,176+@space_y)
    end
    
    def draw_frame
      if(@frame == 0)
        #> Icones Badge
        # Haut
        @badge1.visible = true if($game_switches[130] == true)
        @badge2.visible = true if($game_switches[131] == true)
        @badge3.visible = true if($game_switches[132] == true)
        @badge4.visible = true if($game_switches[133] == true)
        # Bas
        @badge5.visible = true if($game_switches[134] == true)
        @badge6.visible = true if($game_switches[135] == true)
        @badge7.visible = true if($game_switches[136] == true)
        @badge8.visible = true if($game_switches[137] == true)
        #> Icones Frame
        @frame1.visible = @frame2.visible = @frame3.visible = @frame4.visible = false
        @frame5.visible = @frame6.visible = @frame7.visible = @frame8.visible = false
      end
      if(@frame == 1)
        #> Icones Badge
        @badge1.visible = @badge2.visible = @badge3.visible = @badge4.visible = false
        @badge5.visible = @badge6.visible = @badge7.visible = @badge8.visible = false
        #> Icones Frame
        # Haut
        @frame1.visible = true if($game_switches[130] == true)
        @frame2.visible = true if($game_switches[131] == true)
        @frame3.visible = true if($game_switches[132] == true)
        @frame4.visible = true if($game_switches[133] == true)
        # Bas
        @frame5.visible = true if($game_switches[134] == true)
        @frame6.visible = true if($game_switches[135] == true)
        @frame7.visible = true if($game_switches[136] == true)
        @frame8.visible = true if($game_switches[137] == true)
        @frame1.src_rect = @frame2.src_rect = @frame3.src_rect = @frame4.src_rect.set(0,0,32,32)
        @frame5.src_rect = @frame6.src_rect = @frame7.src_rect = @frame8.src_rect.set(0,0,32,32)
      end
      if(@frame == 2)
        @frame1.src_rect = @frame2.src_rect = @frame3.src_rect = @frame4.src_rect.set(32,0,32,32)
        @frame5.src_rect = @frame6.src_rect = @frame7.src_rect = @frame8.src_rect.set(32,0,32,32)
      end
      if(@frame == 3)
        @frame1.src_rect = @frame2.src_rect = @frame3.src_rect = @frame4.src_rect.set(64,0,32,32)
        @frame5.src_rect = @frame6.src_rect = @frame7.src_rect = @frame8.src_rect.set(64,0,32,32)
      end
    end
    
    #> Fin de la scene
    def dispose
      super
      #@background_badge.dispose
      @viewport.dispose
    end
    
  end
end