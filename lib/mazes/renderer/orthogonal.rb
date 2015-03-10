require 'mazes/renderer/grid'

module Mazes
  module Renderer

    class Orthogonal < Grid
      def _setup_renderer(options)
        @tiles = options[:tiles]
        @blocks = options.fetch(:blocks, false)
        @show_walls = options.fetch(:walls, true)
        @size = options[:size] || _default_size
        @inset = ((options[:inset] || 0.0) * @size).round
      end

      def redraw_all
        if @blocks
          @width = @size * (@grid.columns * 2 + 1)
          @height = @size * (@grid.rows * 2 + 1)
        else
          @width = @size * @grid.columns
          @height = @size * @grid.rows

          @width += 2 unless @grid.wrap_horizontal
          @height += 2 unless @grid.wrap_vertical
        end

        @image = ChunkyPNG::Image.new(@width, @height,
          @colors[:background])

        if @blocks
          @grid.rows.times do |row|
            @image.rect(@width-@size, y=row*2*@size, @width, y+@size*2, @colors[:wall], @colors[:wall])
          end

          @grid.columns.times do |col|
            @image.rect(x=col*2*@size, @height-@size, x+@size*2, @height, @colors[:wall], @colors[:wall])
          end

          @image.rect(@width-@size, @height-@size, @width, @height, @colors[:wall], @colors[:wall])
        else
          if !@grid.wrap_horizontal
            @image.line(0, 0, 0, @height-1, @colors[:wall])
            @image.line(@width-1, 0, @width-1, @height-1, @colors[:wall])
          end

          if !@grid.wrap_vertical
            @image.line(0, 0, @width-1, 0, @colors[:wall])
            @image.line(0, @height-1, @width-1, @height-1, @colors[:wall])
          end
        end

        super
      end

      def redraw(cell, style=:background)
        if @blocks
          redraw_with_blocks(cell, style)
        elsif @tiles
          redraw_with_tiles(cell, style)
        elsif @inset > 0
          redraw_with_inset(cell, style)
        else
          redraw_without_inset(cell, style)
        end
        self
      end

      def redraw_with_blocks(cell, style)
        color = @colors[style] || @colors[:background]
        wall = @colors[:wall]

        x1 = @size * cell.column * 2
        x2 = @size * (cell.column * 2 + 1)
        y1 = @size * cell.row * 2
        y2 = @size * (cell.row * 2 + 1)

        @image.rect(x1, y1, x1+@size-1, y1+@size-1, wall, wall)
        @image.rect(x2, y2, x2+@size-1, y2+@size-1, color, color)

        ncolor = cell.linked?(:n) ? color : wall
        wcolor = cell.linked?(:w) ? color : wall

        @image.rect(x2, y1, x2+@size-1, y1+@size-1, ncolor, ncolor)
        @image.rect(x1, y2, x1+@size-1, y2+@size-1, wcolor, wcolor)
      end

      def redraw_with_tiles(cell, style)
        color = @colors[style] || @colors[:background]

        x = 1 + cell.column * @size
        y = 1 + cell.row * @size

        @image.rect(x, y, x+@size-1, y+@size-1, color, color)

        n = cell.linked?(:n)
        s = cell.linked?(:s)
        e = cell.linked?(:e)
        w = cell.linked?(:w)

        key = if n && s && e && w
          :nsew
        elsif n && s && e
          :nse
        elsif n && s && w
          :nsw
        elsif n && e && w
          :new
        elsif s && e && w
          :sew
        elsif w && s
          :ws
        elsif e && s
          :es
        elsif e && n
          :en
        elsif w && n
          :wn
        elsif e && w
          :ew
        elsif n && s
          :ns
        elsif n
          :n
        elsif s
          :s
        elsif e
          :e
        elsif w
          :w
        else
          :blank
        end

        @image.compose!(@tiles[key], x, y)
      end

      def redraw_with_inset(cell, style)
        x1 = 1 + cell.column * @size
        x2 = x1 + @inset
        x4 = x1 + @size - 1
        x3 = x4 - @inset

        y1 = 1 + cell.row * @size
        y2 = y1 + @inset
        y4 = y1 + @size - 1
        y3 = y4 - @inset

        color = @colors[style] || @colors[:background]
        wall = @colors[:wall]

        wcolor = cell.linked?(:w) ? color : @colors[:background]
        ecolor = cell.linked?(:e) ? color : @colors[:background]
        ncolor = cell.linked?(:n) ? color : @colors[:background]
        scolor = cell.linked?(:s) ? color : @colors[:background]

        @image.rect(x2, y2, x3, y3, color, color)
        @image.rect(x1, y2, x2, y3, wcolor, wcolor)
        @image.rect(x3, y2, x4, y3, ecolor, ecolor)
        @image.rect(x2, y1, x3, y2, ncolor, ncolor)
        @image.rect(x2, y3, x3, y4, scolor, scolor)

        if @show_walls
          if cell.linked?(:n)
            @image.line(x2, y1, x2, y2, wall)
            @image.line(x3, y1, x3, y2, wall)
          else
            @image.line(x2, y2, x3, y2, wall)
          end

          if cell.linked?(:s)
            @image.line(x2, y3, x2, y4, wall)
            @image.line(x3, y3, x3, y4, wall)
          else
            @image.line(x2, y3, x3, y3, wall)
          end

          if cell.linked?(:w)
            @image.line(x1, y2, x2, y2, wall)
            @image.line(x1, y3, x2, y3, wall)
          else
            @image.line(x2, y2, x2, y3, wall)
          end

          if cell.linked?(:e)
            @image.line(x3, y2, x4, y2, wall)
            @image.line(x3, y3, x4, y3, wall)
          else
            @image.line(x3, y2, x3, y3, wall)
          end
        end
      end

      def redraw_without_inset(cell, style)
        color = @colors[style] || @colors[:background]
        wall = @colors[:wall]

        x = cell.column * @size
        y = cell.row * @size

        x += 1 unless @grid.wrap_horizontal
        y += 1 unless @grid.wrap_vertical

        @image.rect(x, y, x+@size-1, y+@size-1, color, color)

        if @show_walls
          @image[x, y] = wall
          @image[x+@size-1, y] = wall
          @image[x, y+@size-1] = wall
          @image[x+@size-1, y+@size-1] = wall

          @image.line(x, y, x+@size-1, y, wall) unless cell.linked?(:n)
          @image.line(x, y+@size-1, x+@size-1, y+@size-1, wall) unless cell.linked?(:s)
          @image.line(x, y, x, y+@size-1, wall) unless cell.linked?(:w)
          @image.line(x+@size-1, y, x+@size-1, y+@size-1, wall) unless cell.linked?(:e)
        end
      end

      def _default_size
        width, height = _available_size

        if @blocks
          cell_width = width / (@grid.columns*2+1)
          cell_height = height / (@grid.rows*2+1)
        elsif @tiles
          cell_width = @tiles[:blank].width
          cell_height = @tiles[:blank].height
        else
          cell_width = width / @grid.columns
          cell_height = height / @grid.rows
        end

        [cell_width.to_i, cell_height.to_i].min
      end

    end
  end
end
