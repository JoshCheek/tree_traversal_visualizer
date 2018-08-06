require 'graphics'

class TraverseTree < Graphics::Simulation
  def initialize(tree, radius, w, h)
    super w, h, 31
    @tree              = tree
    @radius            = radius
    @node_font         = find_font "Arial Bold", 32
    @annotation_font   = find_font "Arial Bold", 16

    register_color :leaf, 0x22, 0x66, 0x11, 0x00
    register_color :node, 0x88, 0x44, 0x11, 0x00

    @keys = []
    add = lambda do |key_id, slug, desc, order|
      keydef = [slug, desc, order, :white]
      @keys << keydef
      add_key_handler(key_id) { set_traversal order }
    end
    add['K1', '1', "Pre-order",  :pre]
    add['K2', '2', "In-order",   :in]
    add['K3', '3', "Post-order", :post]

    # just to make it faster to iterate
    set_traversal :pre
  end

  def draw(n)
    clear
    display_keys
    draw_tree @tree
    display_seen @annotation_font, @traverser&.step
    sleep 0.05
  end

  def set_traversal(order)
    @keys.each do |keydef|
      keydef[-1] = (keydef[-2] == order ? :green : :white )
    end
    @traverser = Traverser.new(
      canvas: self,
      order:  order,
      path:   traverse_tree(@tree).to_a,
      font:   @annotation_font,
      radius: @radius,
    )
  end

  def display_seen(font, seen)
    x, y   = 10, 10
    radius = font.height
    label  = "Seen: "
    text label, x, y, :white, font
    x += text_size(label, font)[0]
    seen.each do |tree|
      bg_color = fill_color leaf?(tree)
      str  = Array(tree).first.to_s
      w, h = text_size str, font
      x += radius
      circle x+w/2, y+h/2, radius*0.7, bg_color, true
      text str, x, y, :white, font
      x += w + 5
    end
  end

  def display_keys
    font    = @annotation_font
    row_h   = font.height+5
    x, y    = 10, h-10
    display = lambda do |str, underline, color|
      y -= row_h
      text str, x, y, color, font
      if underline
        line x, y-5, x+100, y-5, color
        y -= 5
      end
    end
    display["Keys", true, :white]
    @keys.map { |key, desc, _, color| display["#{key}: #{desc}", false, color] }
    display["q: quit", false, :white]
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

class Traverser
  attr_reader :canvas, :order, :path, :font, :radius
  def initialize(canvas:, order:, path:, font:, radius:)
    @canvas, @order, @path, @font, @radius = canvas, order, path, font, radius
    @i = 0
  end

  def step
    @i += 1
    call @i
  end

  def call(i)
    line_offset   = radius+10
    marker_offset = radius-3
    px = py       = nil
    seen          = []
    deferred      = []
    path.take(i).each do |crnt_order, tree, xy, *|
      cx, cy = xy
      case crnt_order
      when :pre  then cx -= line_offset
      when :in   then cy -= line_offset
      when :post then cx += line_offset
      else raise "wat: #{crnt_order.inspect}"
      end
      canvas.line px, py, cx, cy, :green if px
      px, py = cx, cy

      next unless order == crnt_order
      seen << tree

      str        = seen.size.to_s
      strw, strh = canvas.text_size str, font
      strx, stry = xy
      case order
      when :pre
        strx -= marker_offset
        strx -= strw
        stry -= strh/2
      when :in
        stry -= marker_offset
        strx -= strw/2
        stry -= strh
      when :post
        strx += marker_offset
        stry -= strh/2
      else raise "wat: #{order.inspect}"
      end
      deferred << lambda do
        circlex = strx+strw/2
        circley = stry+strh/2
        circler = font.height*0.65
        canvas.circle circlex, circley, circler, :red, true
        # canvas.circle circlex, circley, circler, :white, false
        canvas.text str, strx, stry, :white, font
      end
    end
    deferred.each &:call
    seen
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
