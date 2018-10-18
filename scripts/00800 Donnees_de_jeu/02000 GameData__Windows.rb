module GameData
  # Window Builders
  # 
  # Every constants should be Array of integer like this
  #    ConstName = [middle_tile_x, middle_tile_y, middle_tile_width, middle_tile_height, contents_offset_x, contents_offset_y]
  module Windows
    #[GAUCHE,HAUT,?,?,
    MessageWindow = [16,16, 16,16, 16,16] # Message Window
    MessageGold =   [12,11, 16,16, 12,12] # Message Gold
    MessageBattle = [12,11, 16,16, 12,12] # Message battle
    MessageChoice = [16,16, 16,16, 16,16] # Message Choice
    MessageShop =   [16,16, 16,16, 16,32] # Message Shop
  end
end