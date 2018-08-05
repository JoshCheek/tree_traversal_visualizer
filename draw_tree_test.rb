require 'graphics'

class DrawTreeTest < Graphics::Simulation
  def initialize(tree, radius, w, h)
    super w, h, 31
    @tree   = tree
    @radius = radius
    register_color :leaf, 0x22, 0x66, 0x11, 0x00
    register_color :node, 0x88, 0x44, 0x11, 0x00
    @node_font       = find_font "Menlo", 32
    @annotation_font = find_font "Menlo", 10
  end

  def draw(n)
    draw_tree @tree
    traverse_tree(@tree).each_with_index do |(x, y, position), i|
      f   = @annotation_font
      c   = :white
      str = "#{i}: #{position}"
      strw, strh = text_size str, f
      offset = @radius+10
      case position
      when :pre
        text str, x-offset-strw, y-strh/2, c, f
      when :in
        text str, x-strw/2, y-offset-strh, c, f
      when :post
        text str, x+offset, y-strh/2, c, f
      else raise "wat: #{position.inspect}"
      end
    end
  end

  def traverse_tree(tree, col=1, row=1, &block)
    return to_enum(__method__, tree, col, row) unless block
    x, y = center_for col-1, row-1
    content, left, right = tree

    block.call x, y, :pre
    traverse_tree left,  col*2-1, row+1, &block if left
    block.call x, y, :in
    traverse_tree right, col*2,   row+1, &block if right
    block.call x, y, :post
  end

  def draw_tree(tree, col=1, row=1)
    x, y = center_for col-1, row-1
    content, left, right = tree

    draw_node content, x, y, @radius, leaf?(tree)

    if left
      childx, childy = draw_tree left, col*2-1, row+1
      connect_nodes x, y, childx, childy, :white
    end

    if right
      childx, childy = draw_tree right, col*2, row+1
      connect_nodes x, y, childx, childy, :white
    end

    [x, y]
  end

  def draw_node(content, x, y, r, is_leaf)
    detail_color = :white
    fill_color   = (is_leaf ? :leaf : :node)
    circle x, y, r, fill_color, true
    # circle x, y, r,   detail_color
    # circle x, y, r+1, detail_color
    # circle x, y, r+2, detail_color
    text_centered content.to_s, x, y, detail_color, @node_font
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
    row_margin = 50
    num_cols   = 2**row
    col_width  = (w - 2*col_margin) / num_cols
    x = col*col_width + col_width/2 + col_margin
    y = h - (row+1)*(row_margin + 2*@radius)
    [x, y]
  end

  def text_leftj(str, x, y, c, font)
    text str, x, y, c, font
  end

  def text_rightj(str, x, y, c, font)
    strw, strh = text_size str, font
    text str, x-strw, y-strh, c, font
  end

  def text_centered(str, x, y, c, font)
    strw, strh = text_size str, font
    text str, x-strw/2, y-strh/2, c, font
  end

  def text_size(str, font)
    rendered = font.render screen, str, color[:white] # color is irrelevant here
    return rendered.w, rendered.h
  end

  def leaf?(tree)
    content, left, right = tree
    !left && !right
  end
end

tree =
  [:*,
    [:+,
      [:/, 1, 2],
      [:-, 3, 4]],
    [:-,
      [:+, 5, 6],
      [:+, 7, 8]]]

DrawTreeTest.new(tree, 30, 1000, 600).run
