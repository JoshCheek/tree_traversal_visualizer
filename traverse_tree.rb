require 'graphics'

class TraverseTree < Graphics::Simulation
  def initialize(tree, radius, w, h)
    super w, h, 31

    @tree              = tree
    @radius            = radius
    @node_font         = find_font "Menlo", 32
    @annotation_font   = find_font "Menlo", 10
    @instructions_font = find_font "AquaKana", 15

    register_color :leaf, 0x22, 0x66, 0x11, 0x00
    register_color :node, 0x88, 0x44, 0x11, 0x00

    @keys = []
    add_key = lambda do |id, slug, desc, &handler|
      @keys << [slug, desc]
      add_key_handler id, &handler
    end

    add_key.call('K1', '1', "Pre-order Traversal")  { set_traversal :pre }
    add_key.call('K2', '2', "In-order Traversal")   { set_traversal :in }
    add_key.call('K2', '3', "Post-order Traversal") { set_traversal :post }

    @state = :instructions
  end

  def draw(n)
    if n == 1
      display_keys
      draw_tree @tree
      case @state
      when :instructions
      when :traverse
      end
    end
    # draw_traversal @tree
  end

  def display_keys
    font   = @instructions_font
    row_h  = font.height+5
    margin = 10
    key_descs  = @keys.map { |key, desc| "#{key}: #{desc}" }
    ["Keys", *key_descs].each.with_index 1 do |row, i|
      text row, margin, h-margin-row_h*i, :white, font
    end
  end

  def draw_traversal(tree)
    prevxy = nil
    traverse_tree(tree).each_with_index do |(torder, _node, xy, *), i|
      f      = @annotation_font
      str    = i.to_s
      offset = @radius+10
      strw, strh = text_size str, f
      x,    y    = xy
      case torder
      when :pre  then strx, stry = x-offset-strw, y-strh/2
      when :in   then strx, stry = x-strw/2,      y-offset-strh
      when :post then strx, stry = x+offset,      y-strh/2
      else raise "wat: #{torder.inspect}"
      end
      text str, strx, stry, :white, f

      strxy = [strx, stry]
      prevxy && line(*prevxy, *strxy, :green)
      prevxy = strxy
    end
  end

  def draw_tree(tree)
    traverse_tree tree do |torder, node, xy, lxy, rxy|
      next unless torder == :pre
      content, left, right = node
      draw_node content, *xy, @radius, leaf?(node)
      connect_nodes *xy, *lxy, :white if left
      connect_nodes *xy, *rxy, :white if right
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

  def draw_node(content, x, y, r, is_leaf)
    circle x, y, r, fill_color(is_leaf), true
    center_text content.to_s, x, y, :white, @node_font
  end

  def fill_color(is_leaf)
    is_leaf ? :leaf : :node
  end

  def connect_nodes(x1, y1, x2, y2, c)
    ∆x = x2-x1
    ∆y = y2-y1
    h  = Math.sqrt ∆x**2 + ∆y**2
    rx = @radius * ∆x / h
    ry = @radius * ∆y / h
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
    w, h = text_size str, font
    text str, x-w/2, y-h/2, c, font
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
