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


    # now we trace!
    ∆x = x2-x1
    ∆y = y2-y1
    m  = ∆y.to_f/∆x

    # ffs -.- I bet vectors make this way less of a PITA
    ∆nx = -sqrt((margin**2) * (m**2) / (m**2 + 1))

    # upper line
    ux1, uy1 = x1+∆nx, y1-∆nx/m
    ux2, uy2 = x2+∆nx, y2-∆nx/m
    line ux1, uy1, ux2, uy2, :green

    # upper intersections

    # lower line
    ux1, uy1 = x1-∆nx, y1+∆nx/m
    ux2, uy2 = x2-∆nx, y2+∆nx/m
    line ux1, uy1, ux2, uy2, :green
  end

  def dist(x1, y1, nx, ny)
    ∆x = nx-x1
    ∆y = ny-y1
    Math.sqrt(∆x**2 + ∆y**2)
  end
end

Tmp.new.run
