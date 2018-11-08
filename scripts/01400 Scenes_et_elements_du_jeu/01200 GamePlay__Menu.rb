# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Définition du Menu principal
module GamePlay
  class Menu < Base
    attr_accessor :call_skill_process
    def initialize
      super
      @viewport=Viewport.create(:main, 10_000)
      @under_viewport=Viewport.create(:main, 9_999)
      
      @conditions=[$game_switches[Yuki::Sw::Pokedex], #Pokédex possédé
      $actors.size>0, #Possède un Pokémon
      !$bag.locked, #Sac
      @conditions=$game_switches[126], #PoKéMATOS
      true, #Profil / Carte de dresseur
      !$game_system.save_disabled, #Sauvegarde
      true, #Options
      true  #Retour
      ]
      @index=$game_temp.last_menu_index
      #OK
      @Menu_Sprite=Sprite.new(@viewport)
      @Menu_Sprite.bitmap=RPG::Cache.interface("Start_Menu")
      @Menu_Sprite.x = 160
      @Menu_Sprite_Text=Sprite.new(@viewport)
      @Menu_Sprite_Text.bitmap=RPG::Cache.interface("Start_Menu_Sub")
      @Menu_Sprite_Text.src_rect.set(0,0,160,80)
      @Menu_Sprite_Text.y = 208
      #OK
      @sprites=Array.new(@conditions.size)
      @conditions.each_index do |i|
        @sprites[i] = Menu_Item.new(@viewport,i,@conditions[i])
        @sprites[i].set_selected_state(true) if @index==i
      end
      
      @shown=false
      @running=true
    end
    
    def main_begin
      update_index
      @update_spritemap = @__last_scene.class == ::Scene_Map
      super
    end
    
    def main_end
      super
      $game_temp.last_menu_index = @index
    end
    
    def update
      @__last_scene.sprite_set_update if @update_spritemap
      super
      unless @shown
        @sprites.each do |i|
          i.x-=8
        end
        if(@sprites[0].x<=(320-@sprites[0].width))
          @shown=true 
          @sprites.each do |i|
            i.x=320-i.width-2
          end
        end
        return
      end
      if(Input.repeat?(:DOWN))
        @index+=1
        @index=0 if(@index>=@sprites.size)
        update_index
      elsif(Input.repeat?(:UP))
        @index-=1
        @index+=@sprites.size if(@index<0)
        update_index
      elsif(trigger?(:A) or Mouse.trigger?(:left)) # Input.trigger?(:A))
        $game_system.se_play($data_system.decision_se)
        change_scene
      elsif(trigger?(:B)) # Input.trigger?(:B))
        @running = false
      end
    end
    
    #===
    #> Patch du changement de scène
    #===
    def visible=(v)
      super(v & @running)
      return if v == false and @index == 4
      @under_viewport.visible = v & @running
      @__last_scene.sprite_set_visible = v if @update_spritemap
    end
    
    def change_scene
      unless(@conditions[@index])
        #SE impossible
        return
      end
      case @index
      when 1 #Equipe
        @running = false
        @__result_process = proc do |scene|
          if(scene.call_skill_process)
            
            @call_skill_process = scene.call_skill_process
          end
        end
        call_scene(Party_Menu, $actors, :menu)
      when 0 #Pokédex
        call_scene(Dex)
      when 2 #Sac
        call_scene(Bag)
      when 3 #Pokematos
        @running = false
        call_scene(PokeMatos)
      when 4 #Carte de dresseur
        call_scene(TCard)
      when 5 #Sauvegarder
        @running = false
        call_scene(Save)
      when 6 #Options
        call_scene(Config)
      else #Quitter
        @running = false
        @index=0
      end
      @__last_scene.sprite_set_visible = true if @update_spritemap
    end
    
    def update_index
      @sprites.each_index do |i|
        @sprites[i].set_selected_state(@index==i)
      end
      @Menu_Sprite_Text.src_rect.set(0,80+80*@index,160,80)
    end
    
    def dispose
      return if @sprites[0].disposed?
      super
      Graphics.freeze
      @sprites.each do |i|
        i.dispose
      end
      @viewport.dispose
      @under_viewport.dispose
    end
  end
end