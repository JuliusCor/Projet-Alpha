# class that holds information about the font used to draw text on bitmaps
class Font
  # Name of the default PSDK font
  FONT_NAME = "Fonts/PKMN RBYGSC Custom.ttf"
  font_exist = File.exist?(FONT_NAME)#Font.exist?("Pokemon DS")
  # The name of the default font
  FONT_POKEMON = font_exist ? FONT_NAME : "PKMN RBYGSC Custom.ttf"#Font.default_name
  # the "normal" size of the default font
  FONT_SIZE = font_exist ? 8 : 8
  # the small size of the default font
  FONT_SMALL = font_exist ? 16 : 16
  # A constant that passive String#to_pokemon_number
  NoPokemonFont = !font_exist
  Fonts.load_font(0, FONT_POKEMON)
  Fonts.set_default_size(0, FONT_SMALL)
  Fonts.load_font(1, FONT_POKEMON)
  Fonts.set_default_size(1, FONT_SIZE)
end