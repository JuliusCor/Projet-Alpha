# Class that describe a Character Sprite on the Map
class Sprite_Character

  def update
    #>On update RPG::Sprite uniquement si il y a une animation.
    super if @_animation or @_loop_animation
    # Vérification du changement de character
    if @character_name != @character.character_name or @tile_id != @character.tile_id
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      if(@tile_id >= 384)
        self.bitmap = RPG::Cache.tileset($game_map.tileset_name)
        tile_id = @tile_id - 384
        self.src_rect.set(tile_id % 8 * 32, tile_id / 8 * 32, 32, @height = 32)
        self.zoom = 0.5#_x=self.zoom_y=(16*$zoom_factor)/32.0
        self.ox = 16
        self.oy = 32
        @ch = 32
      else
        self.bitmap = RPG::Cache.character(@character_name, 0)
        @cw = bitmap.width / 4
        @height = @ch = bitmap.height / 4
        self.ox = @cw / 2
        self.oy = @ch
        self.zoom = 1 if self.zoom_x != 1
        self.src_rect.set(@character.pattern * @cw, (@character.direction - 2) / 2 * @ch, 
        @cw, @ch)
        @pattern = @character.pattern
        @direction = @character.direction
      end
    end
    # Position du chara sur l'écran
    _x = self.x = @character.screen_x / @zoom
    y = @character.screen_y
    if add = @character.in_swamp
      y += add == 1 ? 4 : 8
    end
    _y = self.y = y / @zoom
    # Pseudo anti-lag
    _x -= self.ox
    _y -= self.oy
    rc = self.viewport.rect
    if _x > rc.width or _y > rc.height + 16 or (_x + self.width) < 0 or (_y + self.height) < 0
      @shadow.visible = false if @shadow
      return self.visible = false
    else
      self.visible = true
    end
  
    #Modification du morceau du character à afficher
    if(@tile_id == 0)
      eax = @character.pattern
      if(@pattern != eax)
        self.src_rect.x = eax*@cw
        @pattern = eax
      end
      eax=@character.direction
      if(@direction != eax)
        self.src_rect.y=(eax - 2) / 2 * @ch
        @direction=eax
      end
    end
    
    # Superiorité
    self.z = (@character.screen_z(@ch) + @add_z)# / @zoom
    # Modification des propriétés d'affichage
#    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    #>Devons nous supprimer la transparence du héros ? 
    #Ca aurait très bien pu être fait avec l'opacité, 
    #c'est con d'utiliser un truc qui touche uniquement le héros sur tous les charas :/
    self.opacity = (@character.transparent ? 0 : @character.opacity)
    # Animation
    if @character.animation_id != 0
      $data_animations    = load_data("Data/Animations.rxdata") unless $data_animations
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
     
    update_bush_depth if @bush_depth > 0
    update_shadow if @shadow
  end
  
end