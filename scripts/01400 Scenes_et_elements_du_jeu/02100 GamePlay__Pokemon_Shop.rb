#noyard
module GamePlay
  class Pokemon_Shop < Shop
    def initialize(pokemon_ids, pokemon_prices, pokemon_levels)
      super()
      @goods = pokemon_ids
      @item_names = Array.new(pokemon_ids.size) { |i| ::GameData::Pokemon.name(pokemon_ids[i]) }
      @item_prices = pokemon_prices
      @pokemon_levels = pokemon_levels
      draw_item_list
      draw_descr
    end
	
    def buy_item(item_id)
      price = @item_prices[index = @goods.index(item_id).to_i]
      if(price == 0 or price > $pokemon_party.money)
        display_message(_parse(11, 24))
        return
      else
        c = display_message(_parse(11,25, ITEM2[0] => ::GameData::Pokemon.name(item_id),
          NUM2[1] => "1", NUM7R => price.to_s), 1,
          _get(11,27), _get(11,28))
        return if(c != 0)
        $pokemon_party.add_pokemon(PFM::Pokemon.new(item_id, @pokemon_levels[index]))
        $pokemon_party.lose_money(price)
        draw_gold_window
        display_message(_get(11,29))
        #> Jouer le bruit du shop
      end
    end
    
    def draw_descr
      if @index < @goods.size
        item_id = @goods[@index]
        #@icon_sprite.bitmap = RPG::Cache.icon(::GameData::Item.b_icon(item_id))
        @descr_text.multiline_text = GameData::Pokemon.descr(item_id)
      else
        @descr_text.text = " "
        #@icon_sprite.bitmap = nil
      end
    end
  end
end