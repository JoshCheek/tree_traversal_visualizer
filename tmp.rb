require 'graphics'
class Tmp < Graphics::Simulation
  include Math

  def initialize
    super 800, 600, 31
  end

  def draw(n)
    # inputs
    margin = 15
    radius = 30
    x1, y1 = 500, 490
    x2, y2 = 275, 380

    # existing drawings
    line x1, y1, x2, y2, :white
    circle x1, y1, radius, :white
    circle x2, y2, radius, :white

    # trace the circles
    tr = radius + margin # trace radius
    circle x1, y1, tr, :green
    circle x2, y2, tr, :green

    # ffs -.- I bet vectors make this way less of a PITA
    m = (y2-y1).to_f/(x2-x1)
    ∆nx = -sqrt((margin**2) * (m**2) / (m**2 + 1))

    # upper line
    ux1, uy1 = x1+∆nx, y1-∆nx/m
    ux2, uy2 = x2+∆nx, y2-∆nx/m
    line ux1, uy1, ux2, uy2, :green

    # upper intersections
    nm = (uy2-uy1) / (ux2-ux1)
    circle *find_intersection(ux1, uy1, nm, x1, y1, tr, -1), 5, :red, true
    circle *find_intersection(ux1, uy1, nm, x2, y2, tr,  1), 5, :red, true

    # lower line
    ux1, uy1 = x1-∆nx, y1+∆nx/m
    ux2, uy2 = x2-∆nx, y2+∆nx/m
    line ux1, uy1, ux2, uy2, :green

    # lower intersections
    nm = (uy2-uy1) / (ux2-ux1)
    circle *find_intersection(ux1, uy1, nm, x1, y1, tr, -1), 5, :red, true
    circle *find_intersection(ux1, uy1, nm, x2, y2, tr,  1), 5, :red, true
  end

  # you don't even want to fucking know how long this took >.<
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

  def dist(x1, y1, nx, ny)
    ∆x = nx-x1
    ∆y = ny-y1
    Math.sqrt(∆x**2 + ∆y**2)
  end
end

Tmp.new.run
