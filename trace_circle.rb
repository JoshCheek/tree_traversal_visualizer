require 'graphics'

class TraceCircle < Graphics::Simulation
  include Math

  def initialize
    super 800, 600, 31
  end

  def draw(n)
    node_arc(w/2, h/2, 0, PI*3/2, 200, 30).take(n).each do |coords|
      line *coords, :white
    end
  end

  def node_arc(x, y, startø, stopø, r, segment_size, &block)
    return to_enum(:node_arc, x, y, startø, stopø, r, segment_size) unless block
    raise "bad angles" if stopø < startø
    ∆ø = segment_size.to_f / r
    prevø = startø
    crntø = prevø + ∆ø
    while crntø < stopø
      block.call *angle_pair_to_xy(x, y, r, prevø, crntø)
      prevø, crntø = crntø, crntø+∆ø
    end
    block.call *angle_pair_to_xy(x, y, r, prevø, stopø)
  end

  def angle_pair_to_xy(x, y, r, ø1, ø2)
    angle_to_xy(x, y, r, ø1) + angle_to_xy(x, y, r, ø2)
  end

  def angle_to_xy(x, y, r, ø)
    [x+r*cos(ø), y+r*sin(ø)]
  end
end


TraceCircle.new.run
