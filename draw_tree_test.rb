require 'graphics'

class DrawTreeTest < Graphics::Simulation
  def initialize(tree)
    super 800, 600, 31
    @tree       = tree
    @radius     = 30
    @row_margin = 20
    @col_margin = 50
  end

  def draw(n)
    draw_pins 1, 1, @tree
  end

  def draw_pins(col, row, tree)
    x, y = center_for col, row
    circle x, y, @radius, :white

    content, left, right = tree # will either destructure or fill left and right in with nil
    centered_text content, x, y, :white
    draw_pins col*2-1, row+1, left   if left
    draw_pins col*2,   row+1, right  if right
  end

  def center_for(col, row)
    num_cols  = 2**(row-1)
    col_width = (w - 2*@col_margin) / num_cols
    x = @col_margin + (col-1) * col_width + col_width/2
    y = h - row*(@row_margin + 2*@radius)
    [x, y]
  end

  def centered_text(content, x, y, c)
    str      = content.to_s
    rendered = font.render screen, str, color[c]
    text str, x-rendered.w/2, y-rendered.h/2, c
  end
end

tree =
  [:*,
    [:+,
      [:/, 9, 3],
      [:-, 7, 8]],
    [:-,
      [:-, [:-, nil, 9], nil],
      [:+, 3, 4]]]

DrawTreeTest.new(tree).run
