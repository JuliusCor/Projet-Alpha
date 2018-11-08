#-------------------------------------------------------------------------------
#Affichage argent pour Maxoumi : Crédit : Eurons, Superfola, Yuri
#-------------------------------------------------------------------------------
class Spriteset_Map
  alias eurons_init_weather_picture_timer init_weather_picture_timer
  def init_weather_picture_timer
    eurons_init_weather_picture_timer
    @pokemon_sprites = Array.new(6) do
      sp = Sprite.new(@viewport2)
      sp.zoom = 0.40
      next(sp)
    end
    #Position de l'argent
    @gold_window = Sprite.new(@viewport)
    @gold_window.bitmap=RPG::Cache.interface("Gold_Window")
    @gold_window.set_position(180,0)
    @argent = Text.new(0, 0, 290, 12, 0, 16, "", 2)
    @actor_clone = nil
    @sw_state = nil
    @last_money = -1
  end
  alias eurons_update_weather_picture update_weather_picture
  def update_weather_picture
    eurons_update_weather_picture
    #Interupteur à changer
    if @actor_clone != $actors or $game_switches[154] != @sw_state or @last_money != $pokemon_party.money
      vsb = @sw_state = $game_switches[154]
      6.times do |i|
      end
      @argent.text = (@last_money = $pokemon_party.money).to_s
      @argent.visible = vsb
      @gold_window.visible = vsb
      @actor_clone = $actors.clone
    end
  end
end