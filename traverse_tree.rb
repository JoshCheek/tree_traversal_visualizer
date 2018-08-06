require 'graphics'
require_relative 'traverser'

class TraverseTree < Graphics::Simulation
  Keydef = Struct.new :key_id, :slug, :name, :description, :order, :color

  def initialize(tree, w, h)
    super w, h, 31, 'Preorder, Inorder, and Postorder Tree Traversal'

    @tree              = tree
    @radius            = 30
    @margin            = 20
    @big_node_font     = find_font "Tahoma Bold", 32
    @small_node_font   = find_font "Tahoma Bold", 16
    @annotation_font   = find_font "Tahoma",      16

    register_color :leaf,       0x22, 0x66, 0x11, 0x00
    register_color :node,       0x88, 0x44, 0x11, 0x00
    register_color :annotation, 0x88, 0x22, 0x22, 0x00

    @keydefs = []
    add = lambda do |key_id, slug, name, order, desc|
      @keydefs << Keydef.new(key_id, slug, name, desc, order, :white)
      add_key_handler(key_id) { set_traversal order }
    end
    add['K1', '1', "Pre-order",  :pre, <<~DESC]
      When you pass the left side of a node, add it to the list!
      In code, this happens *before* you traverse its children.
    DESC
    add['K2', '2', "In-order",   :in, <<~DESC]
      When you pass under a node, add it to the list!
      In code, this happens *between* the traversal of its children.
    DESC
    add['K3', '3', "Post-order", :post, <<~DESC]
      When you pass the right side of a node, add it to the list!
      In code, this happens *after* you traverse its children.
    DESC

    @path = build_traverser(nil)
              .path
              .select { |order, *| order == :pre }
              .map(&:last)

    @started = false
    @label   = ""
    @desc    = "Press the number of the traversal style you'd like to watch."
  end

  def draw(n)
    clear
    display_keys @keydefs, @annotation_font
    display_desc @desc, @annotation_font
    draw_tree @path, @radius, @big_node_font
    display_seen @small_node_font, @label, @traverser&.step if @started
  end

  def build_traverser(order)
    @traverser = Traverser.new(
      canvas: self,
      order:  order,
      font:   @annotation_font,
      radius: @radius,
      tree:   @tree,
      gait:   2,
    )
  end

  def set_traversal(order)
    @keydefs.each do |k|
      if k.order == order
        k.color = :green
        @label = k.name + ": "
        @desc  = k.description
      else
        k.color = :white
      end
    end
    @traverser = build_traverser order
    @started   = true
  end

  def display_seen(font, label, seen)
    x, y   = @margin, @margin
    radius = font.height
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

  def display_keys(keydefs, font)
    row_h   = font.height+5
    x, y    = @margin, h-@margin
    display = lambda do |str, underline, color|
      y -= row_h
      text str, x, y, color, font
      if underline
        line x, y-5, x+100, y-5, color
        y -= 5
      end
    end
    display["Keys", true, :white]
    keydefs.map do |k|
      display["#{k.slug}: #{k.name}", false, k.color]
    end
    display["q: quit", false, :white]
  end

  def display_desc(desc, font)
    y = h-@margin
    desc.lines.map(&:chomp).each do |line|
      line = " " if line.empty?
      strw, strh = text_size line, font
      y -= strh
      text line, w-@margin-strw, y, :white, font
    end
  end

  def draw_tree(path, radius, font)
    path.each do |node, xy, lxy, rxy|
      content, left, right = node
      circle *xy, radius, fill_color(leaf?(node)), true
      center_text content.to_s, *xy, :white, font
      line *line_between_nodes(*xy, *lxy), :white if left
      line *line_between_nodes(*xy, *rxy), :white if right
    end
  end

  def fill_color(is_leaf)
    is_leaf ? :leaf : :node
  end

  def line_between_nodes(x1, y1, x2, y2)
    ∆x = x2-x1
    ∆y = y2-y1
    h  = Math.sqrt ∆x**2 + ∆y**2
    rx = @radius * ∆x / h
    ry = @radius * ∆y / h
    [x1+rx, y1+ry, x2-rx, y2-ry]
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

TraverseTree.new(tree, 1000, 600).run
