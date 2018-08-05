require 'graphics'

class TraverseTree < Graphics::Simulation
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

    traverse_tree(@tree).each_with_index do |(torder, tree, xy, lxy, rxy), i|
      f      = @annotation_font
      c      = :white
      str    = "#{i}: #{torder}"
      offset = @radius+10
      strw, strh = text_size str, f
      x,    y    = xy
      case torder
      when :pre
        text str, x-offset-strw, y-strh/2, c, f
      when :in
        text str, x-strw/2, y-offset-strh, c, f
      when :post
        text str, x+offset, y-strh/2, c, f
      else raise "wat: #{torder.inspect}"
      end
    end
  end

  def traverse_tree(tree, col=0, row=0, &block)
    return to_enum(__method__, tree, col, row) unless block
    lcol = col*2   # left  child column
    rcol = col*2+1 # right child column
    crow = row+1   # child row

    # calculate child locations so we can pass to block before traversing children
    content, left, right = tree
    xy  = center_for  col,  row
    lxy = center_for lcol, crow if left
    rxy = center_for rcol, crow if right

    # the actual traversal
    block.call :pre,  tree, xy, lxy, rxy
    traverse_tree left,  lcol, crow, &block if left
    block.call :in,   tree, xy, lxy, rxy
    traverse_tree right, rcol, crow, &block if right
    block.call :post, tree, xy, lxy, rxy
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
    fill_color = (is_leaf ? :leaf : :node)
    circle x, y, r, fill_color, true

    detail_color = :white
    center_text content.to_s, x, y, detail_color, @node_font
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

  def center_text(str, x, y, c, font)
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

TraverseTree.new(tree, 30, 1000, 600).run
