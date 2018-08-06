class Traverser2
  include Math

  def initialize(canvas:, order:, font:, radius:, tree:)
    @canvas, @font = canvas, font
    @w, @h = canvas.w, canvas.h
    @order, @radius, @tree = order, radius, tree
    @i = 0
    @segment_size = 10
  end

  def step
    margin = radius/2
    path = visit_nodes(@tree, PI*0.5, PI*2.5, margin, 0, 0).to_a
    @i += 1
    call path.take(@i), radius+margin
  end

  private

  PI = Math::PI
  attr_reader :canvas, :order, :font, :radius, :tree
  attr_reader :segment_size


  def visit_nodes(tree, entryø, exitø, margin, col, row, &block)
    return to_enum(__method__, tree, entryø, exitø, margin, col, row) unless block

    content, left, right = tree

    # child cols / rows
    lcol = col*2   # left  child column
    rcol = col*2+1 # right child column
    crow = row+1   # child row

    # coords
    xy  = node_pos  col,  row
    lxy = node_pos lcol, crow
    rxy = node_pos rcol, crow

    # relevant angles
    preø     = PI
    inø      = 3*PI/2
    postø    = 2*PI

    # left child angles
    lc1x = lc1y = :calculated_below
    lc2x = lc2y = :calculated_below
    lc3x = lc3y = :calculated_below
    lc4x = lc4y = :calculated_below

    lc1ø     = :calculated_below
    lc2ø     = :calculated_below
    lc3ø     = :calculated_below
    lc4ø     = :calculated_below

    lambda do
      # consider the line from left child to crnt
      # now give it a stroke of 1 margin on each side
      # wherever the line of its margin goes through
      # the trace radius of the circle, that is our lcstartø
      xcrnt, ycrnt = xy
      xleft, yleft = lxy

      # trace radius
      tr = margin+radius

      # slope
      m   = (yleft-ycrnt).to_f / (xleft-xcrnt)

      # normal
      ∆nx = -sqrt((margin**2) * (m**2) / (m**2 + 1))

      # upper intersection
      ux1, uy1 = xcrnt+∆nx, ycrnt-∆nx/m
      ux2, uy2 = xleft+∆nx, yleft-∆nx/m
      nm = (uy2-uy1) / (ux2-ux1)
      # crnt node to left child
      lc1x, lc1y = find_intersection(ux1, uy1, nm, xcrnt, ycrnt, tr, -1)
      lc1ø = atan2 lc1y-ycrnt, lc1x-xcrnt
      # left child from crnt node
      lc2x, lc2y = find_intersection(ux1, uy1, nm, xleft, yleft, tr,  1)
      lc2ø = atan2 lc2y-yleft, lc2x-xleft


      # lower intersection
      ux1, uy1 = xcrnt-∆nx, ycrnt+∆nx/m
      ux2, uy2 = xleft-∆nx, yleft+∆nx/m
      nm = (uy2-uy1) / (ux2-ux1)
      # left child to crnt node
      lc3x, lc3y = find_intersection(ux1, uy1, nm, xleft, yleft, tr, 1)
      lc3ø = atan2 lc3y-yleft, lc3x-xleft
      # crnt node from left child
      lc4x, lc4y = find_intersection(ux1, uy1, nm, xcrnt, ycrnt, tr, -1)
      lc4ø = atan2 lc4y-ycrnt, lc4x-xcrnt
    end.call

    # right child angles
    rc1x = rc1y = :calculated_below
    rc2x = rc2y = :calculated_below
    rc3x = rc3y = :calculated_below
    rc4x = rc4y = :calculated_below

    rc1ø     = :calculated_below
    rc2ø     = :calculated_below
    rc3ø     = :calculated_below
    rc4ø     = :calculated_below

    lambda do
      xcrnt, ycrnt = xy
      xleft, yleft = rxy

      # trace radius
      tr = margin+radius

      # slope
      m   = (yleft-ycrnt).to_f / (xleft-xcrnt)

      # normal
      ∆nx = -sqrt((margin**2) * (m**2) / (m**2 + 1))

      # upper intersection
      ux1, uy1 = xcrnt+∆nx, ycrnt-∆nx/m
      ux2, uy2 = xleft+∆nx, yleft-∆nx/m
      nm = (uy2-uy1) / (ux2-ux1)
      # crnt node to left child
      rc1x, rc1y = find_intersection(ux1, uy1, nm, xcrnt, ycrnt, tr, 1)
      rc1ø = atan2 rc1y-ycrnt, rc1x-xcrnt
      # left child from crnt node
      rc2x, rc2y = find_intersection(ux1, uy1, nm, xleft, yleft, tr, -1)
      rc2ø = atan2 rc2y-yleft, rc2x-xleft


      # lower intersection
      ux1, uy1 = xcrnt-∆nx, ycrnt+∆nx/m
      ux2, uy2 = xleft-∆nx, yleft+∆nx/m
      nm = (uy2-uy1) / (ux2-ux1)
      # left child to crnt node
      rc3x, rc3y = find_intersection(ux1, uy1, nm, xleft, yleft, tr, -1)
      rc3ø = atan2 rc3y-yleft, rc3x-xleft
      # crnt node from left child
      rc4x, rc4y = find_intersection(ux1, uy1, nm, xcrnt, ycrnt, tr, 1)
      rc4ø = atan2 rc4y-ycrnt, rc4x-xcrnt
    end.call

    # entry -> pre -> left child
    node_arc *xy, entryø, preø, margin  do |x1, y1, x2, y2|
      block.call :line, [x1, y1, x2, y2]
    end
    block.call :pre, [tree, xy, lxy, rxy]
    node_arc *xy, preø, lc1ø, margin  do |x1, y1, x2, y2|
      block.call :line, [x1, y1, x2, y2]
    end

    # left child
    if left
      path_arc lc1x, lc1y, lc2x, lc2y do |x1, y1, x2, y2|
        block.call :line, [x1, y1, x2, y2]
      end
      visit_nodes left, lc2ø, lc3ø, margin, lcol, crow, &block if left
      path_arc lc3x, lc3y, lc4x, lc4y do |x1, y1, x2, y2|
        block.call :line, [x1, y1, x2, y2]
      end
    else
      node_arc *xy, lc1ø, lc4ø, margin do |x1, y1, x2, y2|
        block.call :line, [x1, y1, x2, y2]
      end
    end

    # left child -> infix -> right child
    node_arc *xy, lc4ø, inø, margin do |x1, y1, x2, y2|
      block.call :line, [x1, y1, x2, y2]
    end
    block.call :in, [tree, xy, lxy, rxy]
    node_arc *xy, inø, rc1ø, margin do |x1, y1, x2, y2|
      block.call :line, [x1, y1, x2, y2]
    end

    # right child
    if right
      path_arc rc1x, rc1y, rc2x, rc2y do |x1, y1, x2, y2|
        block.call :line, [x1, y1, x2, y2]
      end
      visit_nodes right, rc2ø, rc3ø, margin, rcol, crow, &block if right
      path_arc rc3x, rc3y, rc4x, rc4y do |x1, y1, x2, y2|
        block.call :line, [x1, y1, x2, y2]
      end
    else
      node_arc *xy, rc1ø, rc4ø, margin do |x1, y1, x2, y2|
        block.call :line, [x1, y1, x2, y2]
      end
    end

    # right child -> post -> exit
    node_arc *xy, rc4ø, postø, margin  do |x1, y1, x2, y2|
      block.call :line, [x1, y1, x2, y2]
    end
    block.call :post, [tree, xy, lxy, rxy]
    node_arc *xy, postø, exitø, margin  do |x1, y1, x2, y2|
      block.call :line, [x1, y1, x2, y2]
    end
  end

  def find_intersection(lx, ly, m, cx, cy, r, dir)
    qa = m*m+1
    qb = 2*(ly*m -lx*m*m - cy*m - cx)
    qc = lx*lx*m*m + -2*lx*ly*m + 2*lx*cy*m +
         ly*ly + -2*ly*cy +
         cy*cy + cx*cx - r*r
    x = quadratic(qa, qb, qc, dir)
    y = (x-lx)*m + ly
    [x, y]
  end

  def quadratic(a, b, c, dir)
    (-b + dir*sqrt(b**2 - 4*a*c)) / 2 / a
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

  def call(path, trace_radius)
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

          strx -= trace_radius
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
      when :line
        canvas.line *vars, :yellow
      else raise "wat: #{type.inspect}"
      end
    end
    deferred.each &:call
    []
  end

  def node_arc(x, y, startø, stopø, margin, &block)
    return to_enum(:node_arc, x, y, startø, stopø, margin) unless block
    startø %= (2*PI)
    stopø  %= (2*PI)
    stopø  += (2*PI) if stopø == 0
    return if stopø < startø
    r  = radius + margin
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

  # this is fkn wrong, it doesn't jump by segment_size,
  # but I just don't have it in me to figure that fucking shit out right now
  def path_arc(x1, y1, x2, y2, &block)
    return to_enum(:path_arc, x1, y1, x2, y2) unless block
    expected_magnitude = (x2-x1).abs
    crnt_magnitude     = 0
    m  = (y2-y1)/(x2-x1)
    x  = x1
    y  = y1
    ∆x = (x2-x1)/10
    while crnt_magnitude.abs < expected_magnitude
      block.call x, y, x+∆x, y+∆x*m
      crnt_magnitude += ∆x
      x += ∆x
      y += ∆x*m
    end
  end

end
