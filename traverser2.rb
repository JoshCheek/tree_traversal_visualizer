class Traverser2
  attr_reader :canvas, :order, :font, :radius, :tree

  def initialize(canvas:, order:, font:, radius:, tree:)
    @canvas, @font = canvas, font
    @w, @h = canvas.w, canvas.h
    @order, @radius, @tree = order, radius, tree
    @i = 0
  end

  def step
    @i += 1
    path = visit_nodes(@tree, PI/2, PI/2, 0, 0).to_a
    call path, @i
  end

  private

  PI = Math::PI

  def visit_nodes(tree, entryø, exitø, col, row, &block)
    return to_enum(__method__, tree, col, row) unless block
    lcol = col*2   # left  child column
    rcol = col*2+1 # right child column
    crow = row+1   # child row

    # calculate child locations so we can pass to block before traversing children
    content, left, right = tree
    xy  = node_pos  col,  row
    lxy = node_pos lcol, crow if left
    rxy = node_pos rcol, crow if right

#   # the actual traversal
#   emit :enter at the entry angle
#   for each line segment around the node, from the entryø to 90deg
#     emit :line

#   emit :pre

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

    block.call :pre,  tree, xy, lxy, rxy
    visit_nodes left,  lcol, crow, &block if left
    block.call :in,   tree, xy, lxy, rxy
    visit_nodes right, rcol, crow, &block if right
    block.call :post, tree, xy, lxy, rxy
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

  def call(path, i)
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
