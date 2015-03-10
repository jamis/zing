require 'mazes/renderer/grid'

module Mazes
  module Renderer

    class Spherical < Grid

      def _setup_renderer(options)
        @show_walls = options.fetch(:walls, true)
        @size = options[:size] || _default_size
      end

      def redraw_all
        @width = @size * @grid.widest + 1
        @height = @size * @grid.rings + 1

        @image = ChunkyPNG::Image.new(@width, @height, @colors[:background])

        @grid.each_cell { |cell| redraw(cell) }

        self
      end

      def redraw(cell, style=:background)
        color = @colors[style] || @colors[:background]
        wall = @colors[:wall]

        ring_size = @grid.spokes(cell.segment, cell.ring)
        cell_width = @width.to_f / ring_size

        x1 = (cell.spoke * cell_width).to_i
        x2 = ((cell.spoke + 1) * cell_width).to_i - 1

        y1 = (cell.ring * @size).to_i
        y2 = ((cell.ring + 1) * @size).to_i

        if cell.segment == @grid.last_segment
          y1 = @height - y1 - 1
          y2 = @height - y2 - 1
          y1 -= 1
        else
          y2 -= 1
        end

        @image.rect(x1, y1, x2, y2, color, color)

        if @show_walls
          if @grid.spokes(cell.segment, cell.ring) > 1
            @image[x1, y1] = wall
            @image[x1, y2] = wall
            @image[x2, y1] = wall
            @image[x2, y2] = wall

            @image.line(x2, y1, x2, y2, wall) unless cell.linked?(:cw)
            @image.line(x1, y1, x1, y2, wall) unless cell.linked?(:ccw)
            @image.line(x1, y1, x2, y1, wall) unless cell.linked?(:inward)
          end

          dw = (x2 - x1 + 1) / cell.outward.length.to_f
          cell.outward.each_with_index do |neighbor, i|
            unless cell.linked?(neighbor)
              @image.line((x1+i*dw).to_i, y2, (x1+(i+1)*dw).to_i, y2, wall)
            end
          end
        end
      end

      def _default_size
        width, height = _available_size

        cell_width = width / @grid.widest
        cell_height = height / @grid.rings

        [cell_width, cell_height].min
      end

    end

  end
end
