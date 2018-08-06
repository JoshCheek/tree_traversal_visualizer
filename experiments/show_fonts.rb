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
  end

  def draw(n)
    clear :black
    x = 50
    y = h-50

    @fonts.each do |name|
      font = find_font name, 20
      y -= font.height
      text name, x, y, :white, font
      y -= 5
      if y < 50
        x += 200
        y = h-50
      end
    end
  end
end

ShowFonts.new.run
