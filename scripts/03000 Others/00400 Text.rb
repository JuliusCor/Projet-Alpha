class Text
  module Util
    # Add a text inside the window, the offset x/y will be adjusted
    # @param x [Integer] the x coordinate of the text surface
    # @param y [Integer] the y coordinate of the text surface
    # @param width [Integer] the width of the text surface
    # @param height [Integer] the height of the text surface
    # @param str [String] the text shown by this object
    # @param align [0, 1, 2] the align of the text in its surface (best effort => no resize), 0 = left, 1 = center, 2 = right
    # @param outlinesize [Integer, nil] the size of the text outline
    # @param type [Class] the type of text
    # @return [LiteRGSS::Text] the text object
    def add_text(x, y, width, height, str, align = 0, outlinesize = nil, type: Text)
      if @window and @window.viewport == @text_viewport
        x += (@ox + @window.x)
        y += (@oy + @window.y)
      end
      # voir pout y - FOY
      text = type.new(@font_id, @text_viewport, x, y - FOY, width, height, str, align, outlinesize)
      text.z = @window ? @window.z + 1 : @text_z
      @texts << text
      text.draw_shadow  = false
      return text
    end
  end
end

test