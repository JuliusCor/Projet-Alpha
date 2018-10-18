# The RPG Maker description of a Party
class Game_Party
  
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 999999].min
  end
  
end