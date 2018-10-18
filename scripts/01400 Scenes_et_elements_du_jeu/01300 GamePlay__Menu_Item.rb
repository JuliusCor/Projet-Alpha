# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Définition d'un élément du menu principale
module GamePlay
  class Menu_Item
    STRINGS=["POKéDEX","POKéMON","SAC","pokeMATOS",nil,"SAUVER","OPTIONS","RETOUR"]
    ALIAS_IDS=[1,0,2,3,4,5,6,7]
    Button="ball_win"
    Icons="Menu_icons"
    TNAME="PROFIL"
    Select_offset=5
    def initialize(viewport,id,enabled)
      @sprite=Sprite.new(viewport)
      @sprite.bitmap=RPG::Cache.interface(Button)
      eax=@sprite.bitmap.height+1
      #@sprite.y=(-46)/2 + eax+15*id
      @sprite.y=(36)/2 + eax+32*id
      @sprite.z=1
      @icon=Sprite.new(viewport)
      @icon.y=@sprite.y-5
      @icon.bitmap=RPG::Cache.interface(Icons)
      @icon.z=2
      eax=@icon.bitmap.height/(STRINGS.size+1)
      @id=(id==2 ? ($trainer.playing_girl ? 7 : 2) : id)
      #>Correction pour afficher dans l'ordre de GF
      #!!CHANGER LA RESSOURCE GRAPHIQUE !
      if(@id==5)
        @id=6
      elsif(@id==6)
        @id=5
      end
      @icon.src_rect.set(0, @id*eax, @icon.bitmap.width/2, eax)
      
      id = ALIAS_IDS[id]
      #>Récupération du texte du menu en fonction de la langue
      if(id !=7)
        #text=_get(14,id).gsub(TNAME, $trainer.name)
        text=_get(14,id).gsub(TNAME, "PROFIL")
      else
        text=STRINGS[7]
      end
      @text = Text.new(0, viewport, 350, @sprite.y - 2, 
        @sprite.bitmap.width-48, @sprite.bitmap.height, text).load_color(enabled ? 0 : 7).set_size(16)
      @text.z = 3
      @disposed=false
      @selected=false
      self.x=320
    end
    
    def x=(v)
      return if @disposed
      v-=Select_offset if @selected
      @sprite.x=v
      @icon.x=166
      @text.x=192
    end
    
    def x
      return 0 if @disposed
      return @sprite.x+Select_offset if @selected
      return @sprite.x
    end
    
    def set_selected_state(v)
      return if @disposed
      x=self.x
      #@selected=v
      self.x=x
      eax=@icon.bitmap.height/(STRINGS.size+1)
      ebx=@icon.bitmap.width/2
      @icon.src_rect.set(v ? ebx : 0, @id*eax, ebx , eax)
    end
    
    def disposed?
      return @disposed
    end
    
    def width
      return @sprite.bitmap.width
    end
    
    def simple_mouse_in?
      @sprite.simple_mouse_in?
    end
    
    def dispose
      return if @disposed
      @text.dispose
      @icon.dispose
      @sprite.dispose
      @disposed=true
    end
  end
end