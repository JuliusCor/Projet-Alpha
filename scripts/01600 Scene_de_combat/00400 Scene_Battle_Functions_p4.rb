#encoding: utf-8

#noyard
# Description: Définition de fonctions utiles ou d'animations pendant la phase 4
class Scene_Battle
  #===
  #>clean_effect
  #Mise à jour des effets d'une équipe de Pokémon
  #===
  def clean_effect(party)
    party.size.times do |i|
      party[i].battle_effect.update_counter(party[i]) unless party[i].dead?
    end
  end
  #===
  #>phase4_cant_display_message
  #Vérification de la possibilité d'affichage des message
  #===
  def phase4_cant_display_message(launcher,target)
    if launcher and launcher.hp==0
      return true
    elsif target and target.hp==0
      return true
    end
    return false
  end
  #===
  #>phase4_message_remove_hp
  #Animation de la perte de HP
  #===
  def phase4_message_remove_hp(pokemon,hp)
    pk_hp=pokemon.hp
    20.times do |i|
      pokemon.hp=pk_hp-hp*i/20
      pokemon.hp=0 if pokemon.hp<0
      status_bar_update(pokemon)
      break if pokemon.hp<=0
      Graphics.update
      update_animated_sprites
    end
    pokemon.hp=pk_hp-hp
    pokemon.hp=0 if pokemon.hp<0
    status_bar_update(pokemon)
    Graphics.update
    update_animated_sprites
    phase4_animation_KO(pokemon) if (pk_hp-hp)<=0
  end
  #===
  #>phase4_message_add_hp
  #Animation du gain de HP
  #===
  def phase4_message_add_hp(pokemon,hp)
    pk_hp=pokemon.hp
    20.times do |i|
      pokemon.hp=pk_hp+hp*i/20
      pokemon.hp=pokemon.max_hp if pokemon.hp>pokemon.max_hp
      status_bar_update(pokemon)
      break if pokemon.hp==pokemon.max_hp
      Graphics.update
      update_animated_sprites
    end
    pokemon.hp=pk_hp+hp
    pokemon.hp=pokemon.max_hp if pokemon.hp>pokemon.max_hp
    status_bar_update(pokemon)
    Graphics.update
    update_animated_sprites
  end
  #===
  #>status_bar_update
  #Mise à jour de la status bar d'un Pokémon
  #===
  def status_bar_update(pokemon)
    if pokemon.position.to_i<0
      bar=@enemy_bars[-pokemon.position-1]
    else
      bar=@actor_bars[pokemon.position]
    end
    return unless bar
    bar.refresh
    bar.update
  end
  #===
  #>phase4_distribute_exp
  #Distribution de l'expérience. pokemon est celui qui est tombé KO
  #===
  def phase4_distribute_exp(pokemon)
    return if $game_switches[::Yuki::Sw::BT_NoExp]
    #Selection des Pokémons qui reçoivent l'expérience
    getters=(pokemon.position<0 ? @actors : @enemies)
    #Si c'est pas le camp de l'attaquant, pas de distribution de l'exp
    #return if !getters.include?(@_launcher) and @_launcher #Retiré à cause des contre coups
    #Somme du nombre de tours
    turn_sum=0
    getters.each do |i|
      turn_sum+=i.battle_turns if i
    end
    #Somme des tours des combattant
    battle_turn=0
    $game_temp.vs_type.times do |j|
      battle_turn+=getters[j].battle_turns if getters[j]
    end
    return if turn_sum==0
    #On scane tous les Pokémons de l'équipe affin de distribuer expérience
    getters.each_index do |j|
      i=getters[j] #Pokémon recevant l'expérience

      #On passe au suivant si le Pokémon n'exste pas, est KO ou est déjà aux max level
      next if !i or i.dead?
      next if i.level>=GameData::MAX_LEVEL

      base_exp=phase4_exp_calculation(pokemon,i) #Expérience récupérée de base
      if(j<$game_temp.vs_type)
        get_exp=base_exp*battle_turn/turn_sum/$game_temp.vs_type
      else
        get_exp=base_exp*i.battle_turns/turn_sum
      end
      #Bonus du multi-exp (exp_totale*50%) // critère 4G
      get_exp+=(base_exp/2) if(i.item_holding == 216 and j>=$game_temp.vs_type)

      next if get_exp==0
      base_exp=i.exp #Expérience de base
      i.add_bonus(pokemon.battle_list) #Distribution des EVs
      text = _parse(18, ((i.item_holding == 216) ? 44 : 43),
      "[VAR 010C(0000)]" => i.given_name,
      NUM7R => get_exp.to_s)
      display_message(text)
      #Boucle de distribution de l'expérience
      given=0
      while given < get_exp and i.level < GameData::MAX_LEVEL
        exp_lvl=i.exp_list[i.level+1].to_i
        exp=(exp_lvl-i.exp_list[i.level])/40
        exp=1 if exp<=0

        #Mise à jour de l'expérience pour le niveau actuel (40 frames = 1 niveau)
        Audio.me_play("Audio/ME/2G_Experience")
        Graphics.wait(4)
        40.times do
          Graphics.wait(1)
          i.exp+=exp
          break if i.exp>exp_lvl or i.exp>(base_exp+get_exp)
          #Si le Pokémon n'est pas sur le terrain on ne met pas la barre à jour
          if(j<$game_temp.vs_type)
            status_bar_update(i)
            Graphics.update
            update_animated_sprites
          end
        end
        Audio.me_stop
        #Ici on recalibre l'expérience totale
        i.exp=exp_lvl if i.exp>exp_lvl
        i.exp=(base_exp+get_exp) if i.exp>(base_exp+get_exp)
        if(j<$game_temp.vs_type) #Mise à jour de la barre affin de bien voir l'arrêt exact
          status_bar_update(i)
          Graphics.update
          update_animated_sprites
        end

        #Si on est au dessus de l'exp nécessaire au niveau, on level up !
        if i.exp >= exp_lvl
          list = i.level_up_stat_refresh
          status_bar_update(i) if j<$game_temp.vs_type
          $game_system.bgm_memorize2
          Audio.bgm_stop
          Audio.se_play("Audio/SE/2G_Level_Up")
          @animation = Sprite.new(@viewport)
            .set_bitmap("animation/Levelup_anim", :interface)
            .set_position(160-34,185-34)
          @animation.z = 99999
          @animation.src_rect.set(68*0,0,68,68)
          Graphics.wait(1)
          @animation.src_rect.set(68*1,0,68,68)
          Graphics.wait(1)
          @animation.src_rect.set(68*2,0,68,68)
          Graphics.wait(1)
          @animation.src_rect.set(68*3,0,68,68)
          Graphics.wait(1)
          @animation.src_rect.set(68*4,0,68,68)
          Graphics.wait(1)
          @animation.src_rect.set(68*5,0,68,68)
          Graphics.wait(1)
          @animation.src_rect.set(68*6,0,68,68)
          Graphics.wait(1)
          @animation.src_rect.set(68*7,0,68,68)
          Graphics.wait(1)
          @animation.src_rect.set(68*8,0,68,68)
          Graphics.wait(1)
          @animation.src_rect.set(68*9,0,68,68)
          Graphics.wait(1)
          @animation.dispose
          Graphics.wait(40)
          $game_system.bgm_restore2
          display_message(_parse(18, 62, '[VAR 010C(0000)]' => i.given_name,
          ::PFM::Text::NUM3[1] => (i.level).to_s))
          i.level_up_window_call(list[0],list[1],@message_window.z+5) if i.position>=0
          @message_window.update
          Graphics.update
          update_animated_sprites
          i.check_skill_and_learn
          @_Evolve<<i unless @_Evolve.include?(i)
        end

        #Mise à jour de l'exp donnée pour savoir si on arrête ou non la boucle
        given=i.exp-base_exp
      end
      i.battle_turns=0
    end
  end
  #===
  #>phase4_exp_calculation
  #Calcul de l'expérience
  #===
  def phase4_exp_calculation(killed,receiver)
    #> Oeuf chance (+50%)
    return (killed.base_exp*killed.level*3/14) if(receiver.battle_item == 231)
    return killed.base_exp*killed.level/7
  end
  #===
  #>phase4_actor_select_pkmn
  # Selection d'un Pokémon pour l'actor
  #===
  def phase4_actor_select_pkmn(i)
    @message_window.visible = false
    $scene = scene = GamePlay::Party_Menu.new(@actors, :battle, no_leave: true)
    scene.main#(true)
    @message_window.visible = true
    $scene = self
    return_data = scene.return_data
    Graphics.transition
    return [2,return_data,i.position]
  end
  #===
  #>phase4_enemie_select_pkmn
  #Vérification de la possibilité d'envoyer un autre ennemi
  #===
  def phase4_enemie_select_pkmn(i)
    #>Temporaire en attendant la reprogrammation de l'IA
=begin
    $game_temp.vs_type.step(@enemies.length-1) do |j|
      if @enemies[j] and !@enemies[j].dead?
        return [2,-j-1,-i.position-1]
      end
    end
=end
    return PFM::IA.request_switch(i)
    #$game_temp.vs_type.step(@enemies.length-1) do |j|
    #  if @enemies[j] and !@enemies[j].dead?
    #    return j
    #  end
    #end
    return false
=begin
    if @enemies[i].dead?
      $game_temp.vs_type.step(@enemies.length-1) do |j|
        if @enemies[j] and !@enemies[j].dead?
          return j
          tmp=@enemies[j]
          @enemies[j]=@enemies[i]
          @enemies[i]=tmp
          return true
        end
      end
      return false
    end
    return false
=end
  end
  #===
  #>phase4_try_to_catch_pokemon
  #Fonction de tentative de capture d'un Pokémon
  #===
  def phase4_try_to_catch_pokemon(ball_data,id)
    pokemon=@enemies[@enemies[0].dead? ? 1 : 0]
    hpmax=pokemon.max_hp*3
    hp=pokemon.hp*2
    rate=pokemon.rareness
    #Calcul du bonus de status
    case pokemon.status
    when 1,2,3,8
      bs=1.5
    when 4,5
      bs=2
    else
      bs=1
    end
    #Calcul du bonus de ball utilisé
    bb=phase4_ball_bonus(ball_data,pokemon)
    #>Mass ball
    if(ball_data.special_catch and ball_data.special_catch[:mass])
      if(pokemon.weight < 100)
        rate -= 20
      elsif(pokemon.weight > 300)
        rate += 30
      elsif(pokemon.weight > 200)
        rate += 20
      end
    end
    if(@safari == true)
      rate += @chance_capture
    end
    #Taux préliminaires
    a=(hpmax-hp)*rate*bs*bb/hpmax
    b=(0xFFFF*(a/255.0)**0.25).to_i
    cnt=0
    4.times do |i|
      cnt+=1 if(rand(0xFFFF)<b)
    end
    return phase4_animation_capture(cnt,pokemon,id)
  end
  #===
  #>phase4_ball_bonus
  #Calcule le bonus conféré par la balle
  #===
  def phase4_ball_bonus(ball_data,pokemon)
    data=ball_data.special_catch
    if(data)
      if(types=data[:types])
        if(types.include?(pokemon.type1) or types.include?(pokemon.type2))
          return (data[:catch_rate] ? data[:catch_rate] : ball_data.catch_rate)
        end
      elsif(data[:level]) #Faiblo ball
        if(pokemon.level<19)
          return 3
        elsif pokemon.level<29
          return 2
        end
      elsif(data[:time]) #Chrono ball
        return (1+$game_temp.battle_turn/25)
      elsif(data[:bis]) #Bis ball
        return 3 if $pokedex.has_captured?(pokemon.id)
      elsif(data[:scuba]) #Scuba ball
        return 3.5 if $env.under_water?#Vérifier si on est sous l'eau
      elsif(data[:dark]) #Sombre ball
        return 4 if $env.night? or $env.cave?#Vérifier si on est la nuit ou dans une grotte
      elsif(data[:speed]) #Speed Ball
        return 4 if $game_temp.battle_turn<6
        return 3 if $game_temp.battle_turn<11
        return 2 if $game_temp.battle_turn<16
      elsif(data[:speed_pk])
        return 4 if pokemon.base_spd >= 100 or $wild_battle.is_roaming?(pokemon)#>Vérifier que le pokémon adverse est rapide
      elsif(data[:appat])
        return 3 if @fished #>Vérifier que le pokémon vient d'être peché
      elsif(data[:level_ball])
        lvl = @actors[0].level
        if(lvl / 4 > pokemon.level)
          return 8
        elsif(lvl / 2 > pokemon.level)
          return 4
        elsif(lvl > pokemon.level)
          return 2
        end
      elsif(data[:moon_ball])
        data = $game_data_pokemon[pokemon.id][pokemon.form]
        if(data.special_evolution and data.special_evolution[:stone]==81)
          return 4
        end
      elsif(data[:love])
        if(@actors[0].gender * pokemon.gender == 2)
          return 8
        end
      end
      return 1
    else
      return ball_data.catch_rate
    end
  end
  #===
  #>phase4_animation_capture
  #Animation de la capture //!!!\\ A terminer !
  #===
  def phase4_animation_capture(cnt,pokemon,id)
    @message_window.auto_skip = true
    display_message(_parse(18,292, TRNAME[0] => $trainer.name))
    Graphics.wait(5)
    init_catch
    #>Recuperation du pokémon adverse
    @poke_sprite = gr_get_pokemon_sprite(pokemon)
    #> ANIMATION : Capture
    gr_launch_ball_to_enemy
    #> ANIMATION : Rebond
    gr_catch_rebond
    #> ANIMATION : Gigotage
    Graphics.wait(30)
    cnt.times do
      gr_animate_ball_on_enemy
    end
    if(cnt==3)
      gr_animate_captured
      #Faire toute la scène de capture
      $game_switches[Yuki::Sw::BT_Catch] = true
      pokemon.captured_with = id
      pokemon.captured_at = Time.new.to_i
      pokemon.trainer_name = $trainer.name
      pokemon.trainer_id = $trainer.id
      pokemon.code_generation(pokemon.shiny, !pokemon.shiny)
      start_phase5
    else
      gr_animate_not_captured
      display_message(_parse(18, 63+rand(4)))
      return phase2_safari_after_ball if(@safari == true)
    end
  end

  #-_-# INIT DE LA CAPTURE #-_-#
  def init_catch
    #>Sprite de la ball de capture ( Pour plus tard )
    @ball_caught=Sprite.new(@viewport)
    @ball_caught.bitmap=RPG::Cache.interface(BallCaught)
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.z = 44000
    @ball_caught.visible = false
    #>Sprite de haut de la ball
    @ball_top=Sprite.new(@viewport)
    @ball_top.bitmap=RPG::Cache.interface(BallCaught)
    @ball_top.src_rect.set(72,0,24,16)
    @ball_top.z = 44001
    @ball_top.visible = false
  end

  #-_-# ANIMATION DE LANCER #-_-#
  def gr_launch_ball_to_enemy
    @waitings = 0
    @ball_caught.visible = true
    #-_-# ANIMATION #-_-#
    3.times do |x|
      @ball_caught.set_position(104+2*x, 140-6*x)
      update_animated_sprites
      Graphics.update
    end
    Audio.se_play("Audio/SE/2G_Launch_Ball")
    15.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(108+2*x, 128-6*x)
      update_animated_sprites
      Graphics.update
    end
    #>Ball droite
    @ball_caught.src_rect.set(48,24,24,48)
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(136+3*x, 44-6*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(142+3*x, 32-5*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(148+4*x, 22-5*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(156+5*x, 12-4*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(166+6*x, 4)
      update_animated_sprites
      Graphics.update
    end
    #>Switch
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(178+4*x, 4+4*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(188+4*x, 12+5*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(196+3*x, 22+5*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(202+3*x, 32+6*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(208+2*x, 44+6*x)
      update_animated_sprites
      Graphics.update
    end
    8.times do |x|
      x = 1 if(x == 0)
      @ball_caught.set_position(208+2*x, 44+6*x)
      update_animated_sprites
      Graphics.update
    end
    @ball_caught.src_rect.set(72,32,24,16)
    @ball_caught.y += 8
    @ball_caught.x += 2
    ##-_-# OUVERTURE #-_-#
    @ball_top.visible = true
    16.times do |x|
      @ball_top.set_position(224, 92-4*x)
      update_animated_sprites
      Graphics.update
    end
    #PHASE : Capture
    gr_catch
    1.step(0, -0.10) do |zoom|
      @poke_sprite.zoom = zoom
      update_animated_sprites
      Graphics.update
    end
    #PHASE : Fermeture
    15.times do |x|
      @ball_top.set_position(224, 32+4*x)
      update_animated_sprites
      Graphics.update
    end
    @ball_top.visible = false
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.y -= 8
  end

  #-_-# ANIMATION DU REBOND #-_-#
  def gr_catch_rebond
    #-_-# REBOND 1 #-_-#
    #                  #
    #-_-# REBOND 1 #-_-#
    21.times do |x|
      x = 1 if(x == 0)
      @ball_caught.y = 92-2*x
      if(x == 10)
        @ball_caught.src_rect.set(24,24,24,24)
        @ball_caught.x = 222
      end
      update_animated_sprites
      Graphics.update
    end
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    y = @ball_caught.y
    21.times do |x|
      x = 1 if(x == 0)
      @ball_caught.y = y+2*x
      if(x == 5)
        @ball_caught.src_rect.set(48,24,24,24)
        @ball_caught.x = 226
      end
      update_animated_sprites
      Graphics.update
    end
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    Audio.se_play("Audio/SE/2G_Ball_Rebond")
    #-_-# REBOND 2 #-_-#
    #                  #
    #-_-# REBOND 2 #-_-#
    19.times do |x|
      x = 1 if(x == 0)
      @ball_caught.y = 92-1.5*x
      if(x == 9)
        @ball_caught.src_rect.set(24,24,24,24)
        @ball_caught.x = 222
      end
      update_animated_sprites
      Graphics.update
    end
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    y = @ball_caught.y
    19.times do |x|
      x = 1 if(x == 0)
      @ball_caught.y = y+1.5*x
      if(x == 4)
        @ball_caught.src_rect.set(48,24,24,24)
        @ball_caught.x = 226
      end
      update_animated_sprites
      Graphics.update
    end
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    Audio.se_play("Audio/SE/2G_Ball_Rebond")
    #-_-# REBOND 3 #-_-#
    #                  #
    #-_-# REBOND 3 #-_-#
    17.times do |x|
      x = 1 if(x == 0)
      @ball_caught.y = 92-1*x
      if(x == 8)
        @ball_caught.src_rect.set(24,24,24,24)
        @ball_caught.x = 222
      end
      update_animated_sprites
      Graphics.update
    end
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    y = @ball_caught.y
    17.times do |x|
      x = 1 if(x == 0)
      @ball_caught.y = y+1*x
      if(x == 4)
        @ball_caught.src_rect.set(48,24,24,24)
        @ball_caught.x = 226
      end
      update_animated_sprites
      Graphics.update
    end
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    Audio.se_play("Audio/SE/2G_Ball_Rebond")
    #-_-# REBOND 4 #-_-#
    #                  #
    #-_-# REBOND 4 #-_-#
    15.times do |x|
      x = 1 if(x == 0)
      @ball_caught.y = 92-0.5*x
      if(x == 7)
        @ball_caught.src_rect.set(24,24,24,24)
        @ball_caught.x = 222
      end
      update_animated_sprites
      Graphics.update
    end
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    y = @ball_caught.y
    15.times do |x|
      x = 1 if(x == 0)
      @ball_caught.y = y+0.5*x
      if(x == 4)
        @ball_caught.src_rect.set(48,24,24,24)
        @ball_caught.x = 226
      end
      update_animated_sprites
      Graphics.update
    end
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    Audio.se_play("Audio/SE/2G_Ball_Rebond")
  end
  
  #-_-# ANIMATION SOUFFLE #-_-#
  def gr_catch
    @open_ball_catch.visible = true
    @open_ball_catch.set_position(216-20, 60)
    @open_ball_catch.src_rect.set(80,0,80,80)
    Audio.se_play("Audio/SE/2G_Open_ball.mp3")
    Graphics.wait(5)
    @open_ball_catch.src_rect.set(160,0,80,80)
    Graphics.wait(5)
    @open_ball_catch.src_rect.set(240,0,80,80)
    Graphics.wait(5)
    @open_ball_catch.src_rect.set(0,0,80,80)
    Graphics.wait(5)
    @open_ball_catch.set_position(40,112)
    @open_ball_catch.visible = false
  end
  
  #-_-# ANIMATION GIGOTAGE #-_-#
  def gr_animate_ball_on_enemy
    Audio.se_play("Audio/SE/2G_Ball_Move")
    @ball_caught.src_rect.set(24,24,24,24)
    @ball_caught.x = 222
    Graphics.wait(8)
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    Graphics.wait(8)
    @ball_caught.src_rect.set(48,24,24,24)
    @ball_caught.x = 226
    Graphics.wait(8)
    @ball_caught.src_rect.set(0,24,24,24)
    @ball_caught.x = 224
    Graphics.wait(48)
  end

  def gr_animate_captured
    @ball_caught.bitmap = RPG::Cache.interface("ball_caught_captured")
    Graphics.wait(10)
    Audio.se_play("Audio/SE/2G_Caught_Jingle")
    @message_window.auto_skip = true
    @message_window.stay_visible = false
    display_message("Et hop ! POKéMON attrapé !")
    Graphics.wait(200)
    @message_window.auto_skip = true
    @message_window.stay_visible = false
  end
    
  def gr_animate_not_captured
    #Graphics.wait(15)
    @ball_caught.dispose
    gr_catch
    @poke_sprite.ajust_position
    0.step(1, 0.1) do |zoom|
      @poke_sprite.zoom = zoom
      update_animated_sprites
      Graphics.update
    end
  end
  
  #===
  #>_phase4_status_check
  #Traitement des effets des status
  #===
  def _phase4_status_check(pkmn)
    return if(!pkmn or pkmn.dead? or BattleEngine::Abilities.has_ability_usable(pkmn,17)) #>Garde Magik
    if(pkmn.poisoned?) #Poison
      #>Soin Poison
      if(BattleEngine::Abilities::has_ability_usable(pkmn,89))
        BattleEngine::_msgp(19, 387, pkmn)
        BattleEngine::_message_stack_push([:hp_up, pkmn, pkmn.poison_effect, true])
      else
        BattleEngine::_msgp(19, 243, pkmn)
        BattleEngine::_mp([:animation_on, pkmn, 469 + pkmn.status])
        BattleEngine::_message_stack_push([:hp_down, pkmn, pkmn.poison_effect, true])
      end
    elsif(pkmn.burn?) #Brûlure
      hp = pkmn.burn_effect
      hp /= 2 if BattleEngine::Abilities::has_ability_usable(pkmn, 117) #> Ignifugé
      BattleEngine::_msgp(19, 261, pkmn)
      BattleEngine::_mp([:animation_on, pkmn, 469 + pkmn.status])
      BattleEngine::_message_stack_push([:hp_down,pkmn,pkmn.burn_effect,true])
    elsif(pkmn.toxic?) #Intoxiqué
      BattleEngine::_msgp(19, 243, pkmn)
      BattleEngine::_mp([:animation_on, pkmn, 469 + pkmn.status])
      BattleEngine::_message_stack_push([:hp_down,pkmn,pkmn.toxic_effect,true])
    end
  end
  #===
  #>switch_pokemon
  # Fonction permettant de réaliser un switch
  #===
  def switch_pokemon(from, to = nil)
    unless @_SWITCH.include?(from)
     @_SWITCH.push(from)
      if(to)
        @_NoChoice[from] = to
      end
    end
  end
  #===
  #>_phase4_switch_check
  # Vérification des switchs à réaliser
  #===
  def _phase4_switch_check
    return @_SWITCH.clear if judge
    to_del = [] #Array des Pokémon à supprimer du tableau de switch
    turn = @phase4_step<@actions.size #>Si on est pas à la fin du tour
    #Affichage des switch A REMANIER !!!!
    @_SWITCH.each do |i|
      next unless i
      next if i.dead? and turn #>Empêcher switch mort avant la fin
      to_del << i
      #>Choix forcé
      if(to = @_NoChoice[i])
        if(i.position < 0)
          phase4_switch_pokemon([2,-@enemies.index(to).to_i-1, -i.position-1])
        else
          phase4_switch_pokemon([2,@actors.index(to).to_i, i.position])
        end
        @_NoChoice.delete(i)
        next
      end
      #>Choix libre
      if i.position<0
        new_enemy=phase4_enemie_select_pkmn(i)
        #phase4_switch_pokemon([2,-new_enemy-1,-i.position-1]) if new_enemy
        phase4_switch_pokemon(new_enemy) if new_enemy
        @e_remaining_pk.redraw if $game_temp.trainer_battle
      else
        #Vérification de la possibilité de switch
        if($game_temp.vs_type==2)
          alive=0
          @actors.each do |j|
            alive+=1 if j and j.hp>0
          end
          next if(alive<2)
        end
        #Tentative de fuite en 1v1 wild
        unless($game_temp.trainer_battle or $game_temp.vs_type==2)
          #r=display_message("Voulez-vous envoyer un autre Pokémon ?\n",false,1,"Oui","Non")
          r=display_message(_get(18, 80),true,1,_get(20, 55),_get(20, 56))
          if(r == 0)
            if(update_phase2_escape(true))
              $game_system.se_play($data_system.escape_se)
              return battle_end(1)
            else
              display_message(_get(18, 77)) #"Impossible de fuire.")
            end
          end
        end
        #Switch si possible
        new_actor=phase4_actor_select_pkmn(i)
        phase4_switch_pokemon(new_actor) if new_actor
        @a_remaining_pk.redraw
      end
    end
    #suppression
    to_del.each do |i|
      @_SWITCH.delete(i)
    end
  end
end
