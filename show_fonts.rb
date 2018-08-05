require 'graphics'
class ShowFonts < Graphics::Simulation
  def initialize
    super 800, 600
    # super 800, 600, 31
    @fonts = %w[
      AquaKana Arial Baskerville Chalkboard Futura Georgia GillSans Helvetica
      Luminari Marion MarkerFelt Menlo Mishafi Mshtakan Muna Optima Papyrus
      Phosphate PingFang PlantagenetCherokee Raanana Rockwell Sana Sathu Seravek
      Shree714 SignPainter Silom Skia Symbol Tahoma Times Verdana
    ]
    @crnt = 0
  end

  def draw(n)
    clear :black

    str = "Keys: 1 (Pre-order Traversal), 2 (In-order Traversal), 3 (Post-order Traversal)"
    font_name = @fonts[@crnt]
    font = find_font font_name, 20
    text "Default", 100, 200, :white
    text str,       100, 150, :white

    text font_name, 100, 400, :white, font
    text str,       100, 350, :white, font
  end
end

ShowFonts.new.run
