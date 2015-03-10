require 'mazes/renderer/grid'

module Mazes
  module Renderer

    class Polar < Grid
      def _setup_renderer(options)
        @show_walls = options.fetch(:walls, true)
        @size = options[:size] || _default_size
      end

      def redraw_all
        @width = @height = 2 * @size * @grid.rings + 1

        @image = ChunkyPNG::Image.new(@width, @height, @colors[:background])
        @center = @width / 2

        @grid.each_cell { |cell| redraw(cell) }

        if @show_walls
          @image.circle(@center, @center, @size * @grid.rings, @colors[:wall])
        end

        self
      end

      def redraw(cell, style=:background)
        color = @colors[style] || @colors[:background]
        wall = @colors[:wall]

        if cell.ring == 0
          @image.circle(@center, @center, @size, color, color)

        else
          theta        = 2 * Math::PI / @grid.spokes(cell.ring)
          inner_radius = cell.ring * @size
          outer_radius = (cell.ring + 1) * @size
          theta_ccw    = cell.spoke * theta
          theta_cw     = (cell.spoke + 1) * theta

          x1 = @center + (inner_radius * Math.cos(theta_ccw)).to_i
          y1 = @center + (inner_radius * Math.sin(theta_ccw)).to_i
          x2 = @center + (outer_radius * Math.cos(theta_ccw)).to_i
          y2 = @center + (outer_radius * Math.sin(theta_ccw)).to_i
          x3 = @center + (inner_radius * Math.cos(theta_cw)).to_i
          y3 = @center + (inner_radius * Math.sin(theta_cw)).to_i
          x4 = @center + (outer_radius * Math.cos(theta_cw)).to_i
          y4 = @center + (outer_radius * Math.sin(theta_cw)).to_i

          outer_points = []
          count = cell.outward.empty? ? 4 : (cell.outward.length + 1)
          theta = theta / (count - 1)
          count.times do |n|
            x = @center + (outer_radius * Math.cos(theta_ccw + theta * n)).to_i
            y = @center + (outer_radius * Math.sin(theta_ccw + theta * n)).to_i
            outer_points << [x,y]
          end
          outer_points << [x4,y4]

          @image.polygon([[x1, y1], *outer_points, [x3, y3]], color, color)

          if @show_walls
            @image.line(x1, y1, x3, y3, wall) unless cell.linked?(:inward)
            @image.line(x3, y3, x4, y4, wall) unless cell.linked?(:cw)
            @image.line(x1, y1, x2, y2, wall) unless cell.linked?(:ccw)
          end
        end
      end

      def _default_size
        diameter = _available_size.min.to_i
        radius = diameter / 2
        radius / @grid.rings
      end

    end
  end
end
