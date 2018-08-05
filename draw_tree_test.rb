require 'graphics'

class DrawTreeTest < Graphics::Simulation
  def initialize(tree)
    super 800, 600, 31
    @tree       = tree
    @radius     = 30
  end

  def draw(n)
    draw_tree 1, 1, @tree
  end

  def draw_tree(col, row, tree)
    x, y = center_for col-1, row-1
    content, left, right = tree

    circle x, y, @radius, :white
    centered_text content.to_s, x, y, :white

    if left
      childx, childy = draw_tree col*2-1, row+1, left
      connect_nodes x, y, childx, childy, :white
    end

    if right
      childx, childy = draw_tree col*2,   row+1, right
      connect_nodes x, y, childx, childy, :white
    end

    [x, y]
  end

  def connect_nodes(x1, y1, x2, y2, c)
    ∆x = x2-x1
    ∆y = y2-y1
    h  = Math.sqrt ∆x**2 + ∆y**2

    rh = @radius / h
    rx = rh*∆x
    ry = rh*∆y

    line x1+rx, y1+ry, x2-rx, y2-ry, c
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

  def centered_text(str, x, y, c)
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
