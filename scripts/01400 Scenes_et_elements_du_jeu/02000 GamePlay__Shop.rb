# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2015
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Définition de la scène d'achat d'objets (Interface temporaire)
module GamePlay
  class Shop < Base
    Selector = "cursor"
    Selector2 = "cursor_black2"
    CursorUp = "cursos_black_up"
    CursorDown = "cursor_black_down"
    Background="White_Background"
    def initialize
      super()
      @viewport = Viewport.create(:main, 1000)
      @index = 0
      #> Image de fond
      @background=Sprite.new(@viewport)
      @background.bitmap=RPG::Cache.interface(Background)
      #> Fenêtre de l'argent
      @gold_window = ::Game_Window.new(@viewport)
      wb = @gold_window.window_builder
      @gold_window.width = 146 #+ wb[0]*2
      @gold_window.height = 32 + wb[1]
      @gold_window.x = 320 - @gold_window.width
      @gold_window.windowskin = RPG::Cache.windowskin("M_1")
      #@gold_window.add_text(0,0,64,16,_get(11, 6))
      @money_text = @gold_window.add_text(48,-6,64,16,_parse(11, 9, 
        NUM7R => $pokemon_party.money.to_s), 2)
      #draw_gold_window
      #> Fenêtre des objets
      @item_window = ::Game_Window.new(@viewport)
      @item_window.y = 2
      @item_window.width = 150 + wb[0]*2
      @item_window.x = 320 - @item_window.width - 2
      @item_window.height = 128 + wb[1]
      @item_window.windowskin = @gold_window.windowskin
      @item_window.visible = false
      #> Selecteur
      @selector = ::Sprite.new(@viewport)
      @selector.x = @item_window.x + wb[0] - 136
      @selector.z = 2
      @selector.bitmap = RPG::Cache.interface(Selector)
      @selector.src_rect.set(0,0,10,14)
      #> Selecteur2
      @selector2 = ::Sprite.new(@viewport)
      @selector2.bitmap = RPG::Cache.interface(Selector)
      @selector2.src_rect.set(10,0,10,14)
      @selector2.visible = false
      #> Arrow UP
      @arrowup = ::Sprite.new(@viewport)
      @arrowup.bitmap = RPG::Cache.interface(Selector)
      @arrowup.src_rect.set(0,0,10,14)
      @arrowup.set_origin_div(2,2)
      @arrowup.angle = 90
      @arrowup.x = 304 - 5
      @arrowup.y = 52 - 7
      @arrowup.visible = false
      #> Arrow Down
      @arrowdown = ::Sprite.new(@viewport)
      @arrowdown.bitmap = RPG::Cache.interface(Selector)
      @arrowdown.src_rect.set(0,0,10,14)
      @arrowdown.set_origin_div(2,2)
      @arrowdown.angle = -90
      @arrowdown.x = 304 - 5
      @arrowdown.y = 178 + 7
      @arrowdown.visible = true
      #>Interface de description
      @descr_window = ::Game_Window.new(@viewport)
      @descr_window.width = 320
      @descr_window.height = 96
      @descr_window.windowskin = @gold_window.windowskin
      @descr_window.y = 288 - @descr_window.height
      @descr_text = @descr_window.add_text(2, 0, 280, 30, " ")
      #@icon_sprite = Sprite.new(@viewport).
      #  set_position(@descr_window.ox + @descr_window.x + 8, @descr_window.oy + @descr_window.y + 8)
      #>Delta y pour le selecteur
      @delta_y = 32 + wb[5]
      i = 0
      @goods = Array.new($game_temp.shop_goods.size) do |i| $game_temp.shop_goods[i][1] end
      @item_names = Array.new(@goods.size) do |i| ::GameData::Item.name(@goods[i]) end
      @item_prices = Array.new(@goods.size) do |i| _parse(22,159, NUM7R => ::GameData::Item.price(@goods[i]).to_s) end
      @price_text = Array.new
      @name_text = Array.new(11) do |cnt|
        @price_text << @item_window.add_text(-21, 54 + cnt*32, 140, 16," ", 2)
        @item_window.add_text(-120, 38 + cnt*32, 142, 16," ")
      end
      draw_item_list
      draw_descr
      @mode = 0
      @counter = 0
    end
    
    def main_begin
      @update_spritemap = @__last_scene.class == ::Scene_Map
      super
    end
    
    def main_end
      super
      $game_temp.last_menu_index = @index
    end
    
    def update
      if(@index > 2)
        @arrowup.visible = true
      else
        @arrowup.visible = false
      end
      if(@index < @goods.size-1)
        @arrowdown.visible = true
      else
        @arrowdown.visible = false
      end
      if(@counter == 0)
        @selector.visible = true
        @selector2.visible = false
        @counter = 5
      elsif(@counter == 1)
        @selector.visible = false
        @selector2.visible = true
        @selector2.x = @selector.x
        @selector2.y = @selector.y
        @counter = 5
      end
      @__last_scene.sprite_set_update if @update_spritemap
      super
      return if $game_temp.message_window_showing
      draw = true
      if Input.repeat?(:UP)
        @index -= 1
        @index = @goods.size if @index < 0
      elsif Input.repeat?(:DOWN)
        @index += 1
        @index = 0 if @index > @goods.size
      elsif(Input.trigger?(:A))
        @counter = 1
        if(@index < @goods.size)
          buy_item(@goods[@index])
        else
          return @running = false
        end
      elsif(Input.trigger?(:B))
        return @running = false
      else
        draw = false
      end
      if draw
        draw_item_list
        draw_descr
      end
    end
    
    def buy_item(item_id)
      price = ::GameData::Item.price(item_id)
      if(price == 0 or price > $pokemon_party.money)
        display_message(_parse(11, 24))
        @counter = 0
        return
      else
        $game_temp.num_input_variable_id = ::Yuki::Var::EnteredNumber
        $game_temp.num_input_digits_max = ($pokemon_party.money/price).to_s.size
        $game_temp.num_input_start = $pokemon_party.money/price
        $game_temp.shop_calling = price
        display_message(_parse(11,23, ITEM2[0] => ::GameData::Item.name(item_id)))
        value = $game_variables[::Yuki::Var::EnteredNumber]
        if(value > 0)
          c = display_message(_parse(11,25, ITEM2[0] => ::GameData::Item.name(item_id),
          NUM2[1] => value.to_s, NUM7R => (value * price).to_s), 1,
          _get(11,27), _get(11,28))
          @counter = 0
          return if(c != 0)
        else
          @counter = 0
          return
        end
        $bag.add_item(item_id, value)
        $pokemon_party.lose_money(value * price)
        draw_gold_window
        display_message(_get(11,29))
        if(item_id == 4 && value >= 10)
          display_message(_get(11,32))
          $bag.add_item(12, 1)
        end
        #> Jouer le bruit du shop
        @counter = 0
      end
      @counter = 0
    end
    
    def draw_descr
      if @index < @goods.size
        item_id = @goods[@index]
        #@icon_sprite.bitmap = RPG::Cache.icon(::GameData::Item.icon(item_id))
        @descr_text.multiline_text = GameData::Item.descr(item_id)
      else
        @descr_text.text = " "
        #@icon_sprite.bitmap = nil
      end
    end
    
    def draw_item_list
      size = @goods.size
      #>Calibrage de l'index initial
      if(@index>2)
        if(size>2 and @index>(size-1))
          ini_index=size-3
        else
          ini_index=@index-2
        end
      else
        ini_index=0
      end
      cnt = -1
      #>Dessin des textes
      ini_index.step(ini_index+3) do |i|
        cnt+=1
        @selector.y = @delta_y + cnt*32 + 8 if(i==@index)
        @price_text[cnt].visible = @name_text[cnt].visible = (i < size)
        if(i>=size)
          if i == size
            @name_text[cnt].text = _get(22,7)
            @name_text[cnt].visible = true
          end
          next
        end
        @name_text[cnt].text = @item_names[i]
        @price_text[cnt].text = @item_prices[i]
      end
    end
    
    def draw_gold_window
      @money_text.text = _parse(11, 9, 
        NUM7R => $pokemon_party.money.to_s)
    end
      
    def dispose
      super
      @gold_window.dispose
      @item_window.dispose
      @descr_window.dispose
      @selector.dispose
      @viewport.dispose
    end
  end
end