# Display a choice Window
# @author Nuri Yuri
class Window_Choice < Game_Window
  # Array of choice colors
  # @return [Array<Integer>]
  attr_accessor :colors
  # Current choix (0~choice_max-1)
  # @return [Integer]
  attr_accessor :index
  # Name of the cursor in Graphics/Windowskins/
  CursorSkin = "Cursor"
  # Name of the windowskin in Graphics/Windowskins/
  WindowSkin = "M_1"
  # Number of choice shown until a relative display is generated
  MaxChoice = 9
  # Index that tells the system to scroll up or down everychoice (relative display)
  DeltaChoice = (MaxChoice / 2.0).round
  # Create a new Window_Choice with the right parameters
  # @param width [Integer] width of the window
  # @param choices [Array<String>] list of choices
  # @param viewport [Viewport, nil] viewport in which the window is displayed
  def initialize(width, choices, viewport = nil)
    super(viewport)
    @text_viewport = Viewport.create(0, 10, width, MaxChoice * 32-16)
    @choices = choices
    @colors = Array.new(@choices.size, get_default_color)
    @index = $game_temp ? $game_temp.choice_start - 1 : 0
    @index = 0 if(@index >= choices.size or @index < 0)
    self.width = width
    build_window
    self.cursor_rect.set(0,0,16,16)
    self.cursorskin = RPG::Cache.windowskin(CursorSkin)
    self.windowskin = RPG::Cache.windowskin(WindowSkin)
    self.active = true
    self.window_builder = GameData::Windows::MessageChoice if($game_switches[26] != true)
    @cursor_ud = 32
    if($game_switches[26] == true or $game_switches[148] == true) #> "BUREAU" PC
      self.window_builder = GameData::Windows::MessageWindow
      @cursor_rect.y = @index * 32 + 14
    elsif($scene.class == GamePlay::Party_Menu) #> PARTY
      @cursor_rect.y = @index * 32
    elsif($scene.class == GamePlay::Bag) #> SAC
      if($game_switches[147] == true)
        @cursor_rect.y = @index * 32 - 2
      else
        @cursor_rect.y = @index * 32 + 14
      end
    elsif($scene.class == GamePlay::StorageBoxDel or $scene.class == GamePlay::StorageBoxAdd or $scene.class == GamePlay::StorageBoxMove or $scene.class == GamePlay::StorageBoxItems) #> PC OLD
      @cursor_rect.y = @index * 32 + 14
    else #> TOUS
      @cursor_rect.y = @index * 32 - 2
    end
    @cursor_rect.y += 1
  end
  # Update the choice, if player hit up or down the choice index changes
  def update
    if(Input.repeat?(:DOWN))
      update_cursor_down
    elsif(Input.repeat?(:UP))
      update_cursor_up
    end
    super
  end
  # Return the default text color
  # @return [Integer]
  def get_default_color
    return 0
  end
  # Return the disable text color
  # @return [Integer]
  def get_disable_color
    return 7
  end
  # Update the choice display when player hit UP
  def update_cursor_up
    if @index == 0
      (@choices.size - 1).times { update_cursor_down }
      return
    end
    if(@choices.size > MaxChoice)
      if(@index < DeltaChoice or 
          @index > (@choices.size - DeltaChoice))
        @cursor_rect.y -= @cursor_ud
      else
        @oy -= 32
        self.y = self.y
      end
    else
      @cursor_rect.y -= @cursor_ud
    end
    @index -= 1
  end
  # Update the choice display when player hit DOWN
  def update_cursor_down
    @index += 1
    if @index >= @choices.size
      @index -= 1
      update_cursor_up until @index == 0
      return
    end
    if(@choices.size > MaxChoice)
      if(@index < DeltaChoice or 
          @index > (@choices.size - DeltaChoice))
        @cursor_rect.y += @cursor_ud
      else
        @oy += 32
        self.y = self.y
      end
    else
      @cursor_rect.y += @cursor_ud
    end
  end
  # Change the window builder and rebuild the window
  def window_builder=(v)
    super(v)
    build_window
  end
  # Build the window : update the height of the window and draw the options
  def build_window
    max = @choices.size
    max = MaxChoice if max > MaxChoice
    self.height = max * 16 + @window_builder[5] * 2
    if($game_switches[26] == true)
    	self.width = 262
    	self.width = 320 if($game_switches[147] == true)#> "BUREAU" PC
    	self.height = 32 + 32*max
    elsif($scene.class == GamePlay::Party_Menu) #> PARTY
    	self.height = max * 36 + 7
    	self.width = 220
    elsif($scene.class == GamePlay::Bag) #> SAC
      self.width = 152
      self.height = max * 32 + 32
      self.x = 320-self.width
      self.y = 288-self.height
      if(@choices.size <= 2)
        if($game_switches[147] == true)
          self.width = 89
          self.height = 80
        end
        self.y = 288-self.height-95
      end
    elsif($game_switches[148] == true) #> SHOP
		  self.width = 176
		  self.height = 144
    else #> TOUS
      self.height += 16 * max - 16
    end
    self.refresh
  end
  # Draw the options
  def refresh
    @texts.each do |text| text.dispose end
    @texts.clear
    @choices.each_index do |i|
      text = @choices[i].clone
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { @colors[i] = $1.to_i ; nil}
      text.gsub!(/\\t\[(.*),(.*)\]/) do ::PFM::Text.parse($1.to_i, $2.to_i) end
      text.gsub!(/\\d\[(.*),(.*)\]/) do $daycare.parse_poke($1.to_i, $2.to_i) end
      if($game_switches[26] == true)
        add_text(0, i * 32, @width+100, 48, text, 0).load_color(@colors[i])
      elsif($scene.class == GamePlay::Party_Menu) #> PARTY
        add_text(0, i * 32 + 2, @width+100, 16, text, 0).load_color(@colors[i])
      elsif($scene.class == GamePlay::Bag) #> SAC
        if($game_switches[147] == true)
          add_text(0, i * 32, @width+100, 16, text, 0).load_color(@colors[i])
        elsif(@choices.size <= 5)
          add_text(0, i * 32, @width+100, 48, text, 0).load_color(@colors[i])
        else
          add_text(0, i * 26, @width+100, 42, text, 0).load_color(@colors[i])
        end
      elsif($game_switches[148] == true) #> SHOP
       	add_text(0, i * 32, @width+100, 48, text, 0).load_color(@colors[i])
      elsif($scene.class == GamePlay::StorageBoxDel or $scene.class == GamePlay::StorageBoxAdd or $scene.class == GamePlay::StorageBoxMove or $scene.class == GamePlay::StorageBoxItems) #> PC OLD
        add_text(0, i * 32, @width+100, 48, text, 0).load_color(@colors[i])
      else #> TOUS
        add_text(0, i * 32, @width+100, 16, text, 0).load_color(@colors[i])
      end
    end
  end
  # Change the z superiority
  # @param v [Numeric]
  def z=(v)
    super(v)
    @text_viewport.z = v + 1
  end
  # Change the x position
  # @param v [Numeric]
  def x=(v)
    super(v)
    v += @window.viewport.rect.x if @window.viewport
    @text_viewport.rect.set(v + 16 + @ox.to_i, nil)
  end
  # Change the y position
  # @param v [Numeric]
  def y=(v)
    super(v)
    v += @window.viewport.rect.y if @window.viewport
    @text_viewport.rect.set(nil, v + @oy.to_i)
  end
  # Tells the choice is done
  # @return [Boolean]
  def validated?
    return (Input.trigger?(:A) or (Mouse.trigger?(:left) and @window.simple_mouse_in?))
  end
  # Function that creates a new Window_Choice for Window_Message
  # @param text [Text] a Text that has the right settings (to calculate the width)
  # @param window [Game_Window] a window that has the right window_builder (to calculate the width)
  # @param intern_window [Game_Window] a window that has the right z superiority (to calculate the z superiority)
  # @return [Window_Choice] the choice window.
  def self.generate_for_message(text, window, intern_window)
    #>Initialisation
    width = w = 10
    #>Calcul de la taille de la fenêtre
    $game_temp.choices.each do |i|
      i = i.gsub(/\\t\[(.*),(.*)\]/) do ::PFM::Text.parse($1.to_i, $2.to_i) end
      i = i.gsub(/\\d\[(.*),(.*)\]/) do $daycare.parse_poke($1.to_i, $2.to_i) end	
      w = text.text_width(i.gsub(/\\[Cc]\[([0-9]+)\]/, nil.to_s))
      width = w if(w > width)
    end
    #>Génération de la fenêtre de choix
    w = window.window_builder[4]
    choice_window = Window_Choice.new(width + w*2 + 16, $game_temp.choices)
    choice_window.z = intern_window.z + 1
    if($game_switches[::Yuki::Sw::MSG_ChoiceOnTop])
      	choice_window.x = choice_window.y = 0
    elsif($game_switches[148] == true) #> SHOP
      	choice_window.x = choice_window.y = 0
    else
      choice_window.x = intern_window.x + window.width - width - w*2 - 16 if $scene.class != GamePlay::Save
      choice_window.x = 0 if $scene.class == GamePlay::Save
      if($game_system.message_position == 2)
        choice_window.y = intern_window.y - choice_window.height
      else
        choice_window.y = intern_window.y + window.height
      end
      choice_window.y = 144 if $scene.class == GamePlay::Save
    end
    Graphics.sort_z
    return choice_window
  end
end