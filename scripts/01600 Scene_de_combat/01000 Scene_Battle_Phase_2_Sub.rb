#encoding: utf-8

#noyard
# Description: Définition de la phase de choix de l'action à réaliser
class Scene_Battle
  #===
  #> Lorsqu'on appuie sur A ou la souris dans la phase 2
  #===
  def on_phase2_validation
    @action_selector.visible = false
    $game_system.se_play($data_system.decision_se)
    case @action_index
    when 0 # => Attaquer
      launch_phase_event(3,false)
      @to_start = :start_phase3
    when 1 # => Pokémon
      phase2_display_team
    when 2 # => Sac
      phase2_display_bag
    when 3 # => Fuite
      phase2_flee
    end
  end

  #===
  #> Lorsqu'on appuie sur A ou la souris dans la phase 2
  #===
  def on_phase2_validation_safari
    @action_selector.visible = false
    $game_system.se_play($data_system.decision_se)
    case @action_index
    when 0 # => Ball
      phase2_ball_safari
    when 1 # => Appat
      phase2_appat_safari
    when 2 # => Caillou
      phase2_caillou_safari
    when 3 # =>  Fuite
      phase2_flee
    end
  end

  #> Capture pokémon Safari
  def phase2_ball_safari
    if($game_variables[113] >= 1)
      $game_variables[113] -= 1
      @chance_flee = @chance_flee*1.5
      phase4_try_to_catch_pokemon($game_data_item[@id_ball].ball_data,@id_ball)
      @chance_capture -= 5
    end
  end

  def phase2_safari_after_ball
    if(@last_add == 0) #> Rien
      phase2_try_flee
    elsif(@last_add == 1) #> Appat
      display_message(_parse(18,288, PKNAME[0] => @enemies[0].name_upper))
      Graphics.wait(20)
      phase2_try_flee
    else #> Caillou
      display_message(_parse(18,289, PKNAME[0] => @enemies[0].name_upper))
      Graphics.wait(20)
      phase2_try_flee
    end
  end

  #> Lancement de l'appat
  def phase2_appat_safari
    @message_window.auto_skip = true
    display_message(_parse(18,290, PKNAME[0] => @enemies[0].name_upper, TRNAME[0] => $trainer.name))
    Graphics.wait(10)
    appat_color = (rand(4)+1)*16
    init_add(appat_color)
    phase2_addnimation(1)
    display_message(_parse(18,288, PKNAME[0] => @enemies[0].name_upper))
    #>> Réduit les chances de fuite du Pokémon, mais rend sa capture plus difficile.
    #>  Voir dans le "Core" pour modifier les chances par default ( PAR DEFAULT : @chance_flee = 5 | @chance_capture = -20)
    #>  ATTENTION ! Seul la fuite est basé sur 100%. La capture c'est un taux !
    #-_-_-# Changements des chances #-_-_-#
    #
    if(@last_add == 1)
      #> Si relancer une autres fois
      @nb_add += 1
      @chance_flee = @chance_flee/(1.5+(@nb_add/10))
    else
      #> Sinon
      @nb_add = 0
      @chance_flee = @chance_flee/1.5
    end
    @chance_capture -= 5
    #>> Remet au minimum si en dessous
    @chance_flee = 0 if(@chance_flee < 0)
    @chance_capture = 0-20 if(@chance_flee < 0-20)
    @last_add = 1
    #
    #-_-_-# Changements des chances #-_-_-#
    phase2_try_flee
  end

  #> Lancement du caillou
  def phase2_caillou_safari
    @message_window.auto_skip = true
    display_message(_parse(18,291, PKNAME[0] => @enemies[0].name_upper, TRNAME[0] => $trainer.name))
    Graphics.wait(10)
    init_add(0)
    phase2_addnimation(2)
    display_message(_parse(18,289, PKNAME[0] => @enemies[0].name_upper))
    #>> Le Pokémon sera plus facile à capturer, mais la probabilité qu'il fuie augmentera.
    #>  Voir dans le "Core" pour modifier les chances par default ( PAR DEFAULT : @chance_flee = 5 | @chance_capture = -20)
    #>  ATTENTION ! Seul la fuite est basé sur 100%. La capture c'est un taux !
    #-_-_-# Changements des chances #-_-_-#
    #
    if(@last_add == 2)
      #> Si relancer une autres fois
      @nb_add += 1
      if(@chance_flee < 5)
        @chance_flee = 9
      else
        @chance_flee = @chance_flee*(1.6+(@nb_add/10))
      end
    else
      #> Sinon
      @nb_add = 0
      if(@chance_flee < 5)
        @chance_flee = 7.5
      else
        @chance_flee = @chance_flee*1.6
      end
    end
    @chance_capture += 10
    #>> Remet au maximum si au dessus
    @chance_flee = 80 if(@chance_flee > 80)
    @chance_capture = 50 if(@chance_capture > 50)
    @last_add = 2
    #
    #-_-_-# Changements des chances #-_-_-#
    phase2_try_flee
  end

  #> Try de la fuite
  def phase2_try_flee
    flee = rand(101) #> Entre 0 et 100%
    if(flee <= @chance_flee)
      display_message(_parse(18,293, PKNAME[0] => @enemies[0].name_upper))
      $game_system.se_play($data_system.escape_se)
      20.times do
        @enemy_sprites[0].x += 7
        Graphics.wait(1)
      end
      battle_end(1)
    else
      start_phase2
    end
  end

  #-_-# INIT DES ADD #-_-#
  def init_add(choice_add)
    #>Sprite de la ball de capture ( Pour plus tard )
    @safari_add=Sprite.new(@viewport)
    @safari_add.bitmap=RPG::Cache.interface("battle/Safari_add")
    @safari_add.src_rect.set(0+choice_add,0,16,16)
    @safari_add.z = 98000
  end

  def phase2_addnimation(choice_add)
    #-_-# ANIMATION #-_-#
    3.times do |x|
      @safari_add.set_position(104+2*x, 140-6*x)
      update_animated_sprites
      Graphics.update
    end
    Audio.se_play("Audio/SE/2G_Launch_Ball")
    15.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(108+2*x, 128-6*x)
      update_animated_sprites
      Graphics.update
    end
    #>Ball droite
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(136+3*x, 44-6*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(142+3*x, 32-5*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(148+4*x, 22-5*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(156+5*x, 12-4*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(166+6*x, 4)
      update_animated_sprites
      Graphics.update
    end
    #>Switch
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(178+4*x, 4+4*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(188+4*x, 12+5*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(196+3*x, 22+5*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(202+3*x, 32+6*x)
      update_animated_sprites
      Graphics.update
    end
    2.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(208+2*x, 44+6*x)
      update_animated_sprites
      Graphics.update
    end
    8.times do |x|
      x = 1 if(x == 0)
      @safari_add.set_position(208+2*x, 44+6*x)
      update_animated_sprites
      Graphics.update
    end
    if(choice_add == 2)
      @safari_add.bitmap=RPG::Cache.interface("battle/Rock_smash")
      @safari_add.set_position(@safari_add.x-14,@safari_add.y-14)
      Graphics.wait(7)
      @safari_add.dispose
      Graphics.wait(10)
    else
      @safari_add.dispose
      Graphics.wait(20)
    end
    
  end

  #===
  #> Affichage de l'interface du sac
  #===
  def phase2_display_bag
    Graphics.freeze
    @message_window.visible = false
    #> Appel interne de l'interface
    scene = GamePlay::Battle_Bag.new(@actors)
    scene.main
    return_data = scene.return_data
    #> Retour sur la scène de combat
    @action_selector.visible = true if return_data == -1
    @message_window.visible = true
    Graphics.transition
    #> Action s'il y a bien eu utilisation d'un objet
    if return_data != -1
      @actor_actions.push([1,return_data])
      $bag.remove_item(return_data[0],1)
      update_phase2_next_act
    end
  end

  #===
  #> Affichage de l'interface de l'équipe
  #===
  def phase2_display_team
    #> Si le Pokémon est bloqué on l'empêche de se faire switch
    return @action_selector.visible = true unless BattleEngine::_can_switch(@actors[@actor_actions.size])
    Graphics.freeze
    @message_window.visible = false
    #> Appel interne de l'interface
    scene = GamePlay::Party_Menu.new(@actors, :battle)
    scene.main
    return_data = scene.return_data
    if(@actor_actions[-1] and @actor_actions[-1][0]==2 and @actor_actions[-1][1]==return_data)
      return_data = -1
    end
    #> Retour à la scène de combat
    @action_selector.visible = true if return_data == -1
    @message_window.visible = true
    Graphics.transition
    #> Action s'il y a bien eu switch de Pokémon
    if return_data != -1
      @actor_actions.push([2,return_data,@actor_actions.size])
      update_phase2_next_act
    end
  end

  #===
  #> Action de fuite
  #===
  def phase2_flee
    #> Vérification de l'empêchement de fuite (blocage ou combat de dresseur)
    t = $game_temp.trainer_battle 
    if t or $game_switches[Yuki::Sw::BT_NoEscape]
      display_message(_get(18,(t ? 79 : 77))) #"Vous ne pouvez pas fuire lors d'un combat de dresseur.")
      @action_selector.visible = true
      start_phase2(@actor_actions.size)
      return
    end
    # Mise à jour de la phase de fuite
    update_phase2_escape
  end

  #===
  #> Calcul du facteur de fuite
  #===
  def phase2_flee_factor
    a = @actors[@actor_actions.size].spd_basis
    b = @enemies[0].spd_basis
    b = 1 if b <= 0
    c = @flee_attempt
    @flee_attempt += 1
    f = ( ( a * 128 ) / b + 30 * c) #% 256 #< Le modulo rend la fuite merdique :/
    pc "Flee factor : #{f}"
    return f
  end
end
