class Scene_Battle
  # Sprite that show the button of a skill to use
  class Skill_Element < UI::SpriteStack
    include UI
    # Create a new Skill_Element
    # @param position [Integer] the position of the element in the interface (0 to 3)
    def initialize(position)
      #super(nil, (position % 2 == 0) ? 0 : 165, (position / 2) * 60 + 38)
      super(nil, 74, (position) * 36 + 134)
      #sprite = push(0, 0, nil, type: AttackDummySprite)
      #sprite.z = 10005 + position
      #sprite.mirror = @x != 0
      add_text(0, 0, 142, 16, :name_upper,    0, type: SymText, color: 0).set_size(16).z = z = 10015 + position
      add_text(30, 16, 144, 16, :pp, 2, type: SymText, color: 0).set_size(16).z = z
      add_text(178, 16, 52, 16, :ppmax, 2, type: SymText).set_size(16).z = z
      #push(8, 31, nil, type: TypeSprite).z = z
      #push(42, 31, nil, type: CategorySprite).z = z
    end
    # Set the skill the element shows
    alias set_skill data=
  end
end