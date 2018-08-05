require 'graphics'

class DrawTreeTest < Graphics::Simulation
  def initialize(tree)
    super 800, 600, 31
    @tree = tree
  end

  def draw(n)
    draw_pins 1, 1, @tree
  end

  RADIUS      = 30
  ROW_HEIGHT  = 50
  COL_WIDTH   = 50
  def draw_pins(col, row, tree)
    center = [2*RADIUS*col, h-(2*RADIUS*row)]
    circle *center, RADIUS, :white

    content, left, right = tree # will either destructure or fill left and right in with nil
    content = content.to_s
    centered_text content, *center, :white
    left  && draw_pins(col*2-1, row+1, left)
    right && draw_pins(col*2,   row+1, right)
  end

  def centered_text(str, x, y, c)
    rendered = font.render screen, str, color[c]
    text str, x-rendered.w/2, y-rendered.h/2, c
  end
end

tree = [
  :*,
  [:+, 1, 5],
  [:-, 10, [:+, 3, 4]],
]

DrawTreeTest.new(tree).run
