class Traverser2
  include Math

  def initialize(canvas:, order:, font:, radius:, tree:)
    @canvas, @font = canvas, font
    @w, @h = canvas.w, canvas.h
    @order, @radius, @tree = order, radius, tree
    @i = 0
  end

  def step
    path = visit_nodes(@tree, PI*0.5, PI*2.5, 0, 0).to_a
    call path.take(@i+=1)
  end

  private

  PI = Math::PI
  attr_reader :canvas, :order, :font, :radius, :tree


  def visit_nodes(tree, entryø, exitø, col, row, &block)
    return to_enum(__method__, tree, entryø, exitø, col, row) unless block
    segment_size  = 10
    trace_readius = 2 * radius

    preø  = PI
    inø   = 3*PI/2
    postø = 2*PI

    lcol = col*2   # left  child column
    rcol = col*2+1 # right child column
    crow = row+1   # child row

    # calculate child locations so we can pass to block before traversing children
    content, left, right = tree
    xy  = node_pos  col,  row
    lxy = node_pos lcol, crow if left
    rxy = node_pos rcol, crow if right

    # the actual tracing traversal
    block.call :enter, tree, xy, entryø, exitø

    node_arc *xy, entryø, preø, trace_readius, segment_size  do |x1, y1, x2, y2|
      block.call :line, [x1, y1, x2, y2]
    end

    block.call :pre, [tree, xy, lxy, rxy]

#   for each line segment from 90 to lcstart
#     emit :line

#   if there is a left child
#     emit :exit
#     for each line segment along the connection
#       emit :line
#     visit left child
#     for each line segment along the connection coming back
#       emit :line
#     emit :enter
#   else
#     for each line segment from lcstart to lcend
#       emit :line

#   for each line segment from lcend to rcstart
#     emit :line

#   if there is a right child
#     emit :exit
#     for each line segment along the connection
#       emit :line
#     visit right child
#     for each line segment along the connection coming back
#       emit :line
#     emit :enter
#   else
#     for each line segment from ccstart to rcend
#       emit :line

#   for each line segment from rcend to exitø
#     emit line

    idk1ø = PI/2 + 0.5
    idk2ø = PI/2 - 0.5

    visit_nodes left,  idk1ø, idk2ø, lcol, crow, &block if left
    # block.call :in,   [tree, xy, lxy, rxy]
    visit_nodes right, idk1ø, idk2ø, rcol, crow, &block if right
    # block.call :post, [tree, xy, lxy, rxy]
  end

  def node_pos(col, row)
    col_margin = 50
    row_margin = 50
    num_cols   = 2**row
    col_width  = (@w - 2*col_margin) / num_cols
    x = col*col_width + col_width/2 + col_margin
    y = @h - (row+1)*(row_margin + 2*@radius)
    [x, y]
  end

  def call(path)
    line_offset   = radius+10
    marker_offset = radius-3
    deferred      = []
    seen          = []
    path.each do |type, vars|
      case type
      when :pre
        tree, xy, * = vars
        if type == order
          seen << tree
          str        = seen.size.to_s
          strw, strh = canvas.text_size str, font
          strx, stry = xy

          strx -= marker_offset
          strx -= strw
          stry -= strh/2

          deferred << lambda do
            circlex = strx+strw/2
            circley = stry+strh/2
            circler = font.height*0.65
            canvas.circle circlex, circley, circler, :red, true
            # canvas.circle circlex, circley, circler, :white, false
            canvas.text str, strx, stry, :white, font
          end
        end
      when :in
        tree, xy, * = vars
      when :post
        tree, xy, * = vars
      when :enter
      when :line
        canvas.line *vars, :yellow
      else raise "wat: #{type.inspect}"
      end
    end
    deferred.each &:call
    []
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
    [x+r*Math.cos(ø), y+r*Math.sin(ø)]
  end

end
