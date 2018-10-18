class Viewport
  def self.create(x, y = 0, width = 1, height = 1, z = nil)
    if(x.class == Hash)
      z = x.fetch(:z, nil)
      y = x.fetch(:y, 0)
      width = x.fetch(:width, 320)
      height = x.fetch(:height, 288)
      x = x.fetch(:x, 0)
    elsif(x == :main or x == :sub)
      z = y
      if(x == :main)
        x = ::Config::Viewport::X
        y = ::Config::Viewport::Y
        width = ::Config::Viewport::Width
        height = ::Config::Viewport::Height
      else
        x = ::Config::Viewport::Sub_X
        y = ::Config::Viewport::Sub_Y
        width = ::Config::Viewport::Sub_Width
        height = ::Config::Viewport::Sub_Height
      end
    end
    v = Viewport.new(x, y, width, height)
    v.z = z if z
    return v
  end
end