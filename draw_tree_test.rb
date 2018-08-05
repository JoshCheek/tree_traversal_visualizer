require 'graphics'

class DrawTreeTest < Graphics::Simulation
  def initialize(tree)
    super 800, 600, 31
    @tree       = tree
    @radius     = 30
  end

  def draw(n)
    draw_node 1, 1, @tree
  end

  def draw_node(col, row, tree)
    x, y = center_for col-1, row-1
    circle x, y, @radius, :white

    content, left, right = tree
    centered_text content, x, y, :white
    if left
      draw_node col*2-1, row+1, left
    end
    if right
      draw_node col*2,   row+1, right
    end
  end

  def center_for(col, row)
    col_margin = 50
    row_margin = 20
    num_cols   = 2**row
    col_width  = (w - 2*col_margin) / num_cols
    x = col*col_width + col_width/2 + col_margin
    y = h - (row+1)*(row_margin + 2*@radius)
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
