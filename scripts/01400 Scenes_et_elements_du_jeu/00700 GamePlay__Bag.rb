# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Interface du sac
module GamePlay
  class Bag
    #> Inclusions
    include ::Util::Item
    #> Définition des Constantes
    Bag_Dir="Graphics/bag/"
    ESPACE=" "
    GIVE="DONNER"
    USE="UTILISER"
    THROW="JETER"
    SELECT="SELECTIONNER"
    SELL="VENDRE"
    CANCEL="ANNULER"
    MOVE="DEPLACER"
    SORT_ALPHA="TRI ALPHABETIQUE"
    SORT_ID="TRI PAR DEFAUTS"
    Socket_Names=[nil.to_s,"Objets","Pokéball","CT/CS","Baies","Objets Rare","Médicaments"]
    Bag_IMG=["bag","bag_girl"]
    LineJump="\n"
    Battle_Socket=[1,2,4,6]
    include Text::Util
    attr_accessor :return_data #ID de l'objet retourné
    #===
    #>Initialisation du sac
    #===
    def initialize(mode=:menu)
      super()
      #>Definition des variable de fonctionnement de l'interface
      @mode = mode
      @return_data = -1
      @moving = false
      _adjust_socket(mode)
      _calibrate_item_list
      #>Definition des sprites
      @viewport = select_view(view(:main, 10000))
      #>Fond
      @background = background(nil)
      #>Sac
      @bag = sprite(Bag_IMG[$trainer.playing_girl ? 1 : 0], -100, -100, 1, ox_div: 2, oy_div: 12)
      _bag_src_rect_gen
      #> Icone
      @icon = sprite(nil, 58, 150, 2)
      @icon.visible = false
      #> Selecteur
      @selector = sprite("cursor_red", 106, 128, 2)
      @selector2 = sprite("cursor_red2", 106, 128, 2)
      @selector2.visible = false
      @select_order = 0
      @key = 0
      #> Textes
      init_text(0, @viewport)
      #Texte OSEF ( Nom du sac actuel )
      @socket_text = add_text(-600, -600, 113, 23, " ", 1, 1).load_color(0)
      @quantity_text = Array.new
      @textx = Array.new
      @name_text = Array.new(11) do |cnt|
        #Quantité objet
        @quantity_text << add_text(176, 48 + cnt* 32, 140, 16," ", 2)
        #Image "X"
        @textx[cnt] = sprite("bag_x", 256, 52 + cnt* 32, 2)
        #Nom Objet
        add_text(120, 32 + cnt* 32, 140, 16," ",0)
      end
      #Description objets
      @descr_window = sprite("window_sprite_1", 0, 192, 2)
      @descr_text = add_text(16, 216, 280, 32, " ")
    end

    #===
    #>Méthode de fonctionnement générale
    #===
    def main_begin
      _draw_stuff
      super
    end
    
    def main_end
      super
      @item_names.clear
      @item_names=nil
      $bag.last_socket=@socket
      $bag.last_index=@index
    end
    #===
    #>Mise à jour de la scène
    #===
    def update
      super
      return if $game_temp.message_window_showing
      if(repeat?(:UP))
        @key = 1 if(@selector.y == 96)
        @index-=1
        @index=0 if @index<0
        return _draw_stuff
      elsif(repeat?(:DOWN))
        @key = 2 if(@selector.y == 96)
        @index+=1
        @index=@item_ids.size if @index>@item_ids.size
        return _draw_stuff
      elsif(repeat?(:RIGHT) and @mode!=:berry and !@moving)
        @socket+=1
        @socket=1 if @socket>6
        @item_ids=$bag.get_order(@socket)
        @item_names.clear
        @item_names=_item_name_list_gen
        _bag_src_rect_gen
        @index=0
        return _draw_stuff
      elsif(repeat?(:LEFT) and @mode!=:berry and !@moving)
        @socket-=1
        @socket=6 if @socket<1
        @item_ids=$bag.get_order(@socket)
        @item_names.clear
        @item_names=_item_name_list_gen
        _bag_src_rect_gen
        @index=0
        return _draw_stuff
      end
      if(trigger?(:B))
        @return_data=-1
        return _close_bag
      elsif(trigger?(:A))
        $game_system.se_play($data_system.decision_se)
        if(@index==@item_ids.size)
          return if @moving
          @return_data=-1
          return _close_bag
        else
          return _action_on_item
        end
      end
    end
    #===
    #>Quand on utilise un objet
    #===
    def _action_on_item
      @selector2.y = @selector.y
      @selector.visible = false
      @selector2.visible = true
      @select_order = 1
      @return_data=@item_ids[@index]
      if(@moving)
        #>Si get_order change, il faut changer ce code !
        origin = @item_ids.index(@moving)
        @item_ids[origin]=nil
        @item_ids.insert(@index + ((@index-origin > 0) ? 1 : 0),@moving)
        @item_ids.compact!
        #@selector.sy = 0#@selector.src_rect.y = 0 #@selector.color=Color.new(0,0,0,0)
        @item_names=_item_name_list_gen
        _draw_stuff
        @moving=false
        @selector.visible = true
        @selector2.visible = false
        @select_order = 0
        return
      end
      case @mode
      when :menu
        choix=_bag_window(_get(22,0),_get(22,3),_get(22,177),_get(22,81),_get(22,84),_get(22,1))
        if(choix==0)
          return _use_item
        elsif(choix==1)
          return _give_item
        elsif(choix==2)
          @selector.visible = true
          @moving=@return_data
          #@selector.sy = 1#@selector.src_rect.y = @selector.src_rect.height#@selector.color=Color.new(0,160,0,255)
          return
        elsif(choix==3)
          $bag.sort_alpha(@socket)
          @item_names.clear
          @item_names=_item_name_list_gen
          @selector.visible = true
          @selector2.visible = false
          @select_order = 0
          return _draw_stuff
        elsif(choix==4)
          $bag.reset_order(@socket)
          @item_names.clear
          @item_names=_item_name_list_gen
          @selector.visible = true
          @selector2.visible = false
          @select_order = 0
          return _draw_stuff
        elsif(choix==5)
          return _throw_item
        end
      when :map,:berry
        return _close_bag if(_bag_window(_get(22,0))==0)
      when :hold
        return _close_bag if(_bag_window(_get(22,3))==0)
      when :shop
        #if(_bag_window(_get(11,1))==0)
        #  sell_item
        #end
        sell_item
      end
      @selector.visible = true
      @selector2.visible = false
      @select_order = 0
    end
    #===
    #>Quand on ferme le sac
    #===
    def _close_bag
      case @mode
      when :menu #Ouverture depuis le menu
        @running = false#$scene=Scene_Map.new #Remplacer par le menu
      when :map,:berry, :shop #Ouverture depuis un évent
        return_to_scene(Scene_Map)#$scene=Scene_Map.new
      when :hold #Requette d'ouverture depuis l'équipe
        @running = false #$scene=nil
      end
    end
    #===
    #>Dessin de la scène
    #===
    def _draw_stuff
      @socket_text.text = Socket_Names[@socket]
      size = @item_ids.size
      ini_index = 0
      #>Calibrage de l'index initial
      if(@index > 2)
        if(size > 4 and @index > (size - 2))
          ini_index = size - 4
        else
          ini_index = @index - 2
        end
      else
        ini_index = 0
      end
      cnt = -1
      ini_index.step(ini_index + 4) do |i|
        cnt += 1
        @selector.y = 32 + cnt*32 if(i == @index)
        @quantity_text[cnt].visible = false
        @textx[cnt].visible = i < size
        @name_text[cnt].visible = i <= size
        if i >= size
          @name_text[cnt].text = _get(22, 7) if i == size
          next
        end
        @name_text[cnt].text = @item_names[i]
        if GameData::Item.limited_use?(@item_ids[i])
          @quantity_text[cnt].visible = true
          @quantity_text[cnt].text = $bag.item_quantity(@item_ids[i]).to_s
        end
      end
      @icon.bitmap = RPG::Cache.icon(GameData::Item.icon(@item_ids[@index].to_i))
      @icon.ox = @icon.bitmap.width / 2
      @icon.oy = @icon.bitmap.height / 2
      #>Dessin de la description
      return @descr_text.text = " " unless @item_ids[@index]
      @descr_text.multiline_text = GameData::Item.descr(@item_ids[@index])
      #>Selector :UP
      if(@key == 1)
        if(@selector.y == 96)
          @selector2.y += 32
        end
        if(@selector.y > 160 or @selector2.y < 32)
          @selector2.visible = false
        else
          @selector2.visible = true if(@select_order == 1)
        end
      end
      #>Selector :DOWN
      if(@key == 2)
        if(@selector.y == 96)
          @selector2.y -= 32
        end
        if(@selector2.y < 32)
          @selector2.visible = false
        else
          @selector2.visible = true if(@select_order == 1)
        end
      end
      @key = 0
    end
    #===
    #> Correction de la socket en fonction des conditions
    #===
    def _adjust_socket(mode)
      if(mode==:battle)
        @socket = $bag.last_socket
        if(Battle_Socket.include?(@socket))
          @index = $bag.last_index
        else
          @socket = 1
          @index = 0
        end
      elsif(mode != :berry)
        @socket = $bag.last_socket
        @index = $bag.last_index
      else #Si on cherche à planter des baies, on bloque sur la poche 4
        @socket = 4
        @index = 0
      end
    end
    #===
    #>Génération du src_rect du sac
    #===
    def _bag_src_rect_gen
      @background.bitmap=RPG::Cache.interface("Bag_Background#{@socket}")
      height=@bag.bitmap.height/6 #6poches
      y=(@socket-1)*height
      @bag.src_rect.set(0,y,@bag.bitmap.width,height)
    end
    #===
    #>Fenêtre d'action du sac
    #===
    def _bag_window(*args)
      window=Window_Choice.new(240,args+[_get(22,7)])
      window.z=@viewport.z+1
      window.x=80
      window.y=224-window.height
      window.height += 64
      Graphics.sort_z
      give = _get(22,3)
      throw = _get(22,1)
      use = _get(22,0)
      item_id=@item_ids[@index]
      disabled=[]
      args.each_index do |i|
        cmd=args[i]
        if((cmd==give and !GameData::Item.holdable?(item_id)) or
           (cmd==throw and !GameData::Item.limited_use?(item_id)) or
           (cmd==use and (!GameData::Item.map_usable?(item_id) or 
           (@mode == :berry and !GameData::ItemMisc.berry(item_id)))))
          window.colors[i]=7
          disabled<<i
        end
      end
      window.refresh
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
        elsif(trigger?(:B))
          window.index=args.size
          break
        end
      end
      index=window.index
      window.dispose
      return index
    end
    #===
    #>Utilisation d'un objet
    #===
    def _use_item
      item_id = @item_ids[@index]
      extend_data = util_item_useitem(item_id)
      return extend_data unless extend_data
      @selector.visible = true
      @selector2.visible = false
      @select_order = 0
      _calibrate_item_list
      _draw_stuff
      return extend_data
    end
    #===
    #>Donner un objet
    #===
    def _give_item
      call_scene(Party_Menu, $actors, :hold, @item_ids[@index])
      _calibrate_item_list
      _draw_stuff
      @selector.visible = true
      @selector2.visible = false
      @select_order = 0
    end
    #===
    #>Jeter un objet
    #===
    def _throw_item
      $game_temp.num_input_variable_id = ::Yuki::Var::EnteredNumber
      $game_temp.num_input_digits_max = $bag.item_quantity(@return_data).to_s.size
      $game_temp.num_input_start = $bag.item_quantity(@return_data)
      display_message(_parse(22, 38, ::PFM::Text::ITEM2[0] => GameData::Item.name(@return_data)))
      value = $game_variables[::Yuki::Var::EnteredNumber]
      if(value > 0)
        _calibrate_item_list
        _draw_stuff
        display_message(_parse(22, 39, ::PFM::Text::ITEM2[0] => GameData::Item.name(@return_data),
          ::PFM::Text::NUM3[1] => value.to_s))
        $bag.remove_item(@return_data, value)
      end
      @selector.visible = true
      @selector2.visible = false
      @select_order = 0
    end
    #===
    #> Vendre un objet
    #===
    def sell_item
      price = GameData::Item.price(@return_data) / 2
      if(price > 0)
        $game_temp.num_input_variable_id = ::Yuki::Var::EnteredNumber
        $game_temp.num_input_digits_max = $bag.item_quantity(@return_data).to_s.size
        $game_temp.num_input_start = $bag.item_quantity(@return_data)
        $game_temp.shop_calling = price
        display_message(_parse(22,170, ITEM2[0] => ::GameData::Item.name(@return_data)))
        $game_temp.shop_calling = false
        value = $game_variables[::Yuki::Var::EnteredNumber]
        if(value > 0)
          c = display_message(_parse(22,171, NUM7R => (value * price).to_s),
          1, _get(11,27), _get(11,28))
          return if(c != 0)
        else
          return
        end
        $bag.remove_item(@return_data, value)
        $pokemon_party.add_money(value * price)
        _calibrate_item_list
        _draw_stuff
        display_message(_parse(22,172, NUM7R => (value * price).to_s))
      else
        ::PFM::Text.set_plural(false)
        display_message(_parse(22,174, ITEM2[0] => ::GameData::Item.name(@return_data)))
      end
    end
    #===
    #>Calibration de la liste des objets
    #===
    def _calibrate_item_list
      @item_ids=$bag.get_order(@socket)
      @item_names=_item_name_list_gen
      @index=@item_ids.size if @index>@item_ids.size #Il y a l'option retour
    end
  end
end