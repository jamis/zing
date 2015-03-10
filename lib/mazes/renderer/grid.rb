require 'mazes/renderer/base'

module Mazes
  module Renderer

    class Grid < Base
      DEFAULT_COLORS = {
        background: ChunkyPNG::Color::WHITE,
        wall:       ChunkyPNG::Color::BLACK,
        highlight:  ChunkyPNG::Color.rgb(255,255,128) }

      attr_reader :colors
      attr_reader :grid

      def initialize(grid, target, options={})
        super target

        @grid = grid
        self.colors = options[:colors] || {}
        _setup_renderer(options)

        redraw_all
      end

      def _setup_renderer(options)
        raise NotImplementedError
      end

      def colors=(map)
        @colors = DEFAULT_COLORS.merge(map)
      end

      def color_path(path, style=:highlight)
        path.each { |cell| redraw(cell, style) }
        self
      end

      def redraw_all
        @grid.each_cell { |cell| redraw(cell) }
        self
      end

      def redraw_all!
        redraw_all.save_frame
      end

      def redraw(cell, style=:background)
        raise NotImplementedError
      end

      def update(*cells)
        _make_cell_list(*cells).each do |cell, style|
          next if cell.nil?
          redraw(cell, style)
        end

        self
      end

      def update!(*cells)
        update(*cells).save_frame
      end

      def snapshot!(*cells)
        cells = _make_cell_list(*cells)
        update!(cells)
        update(*cells.keys)
      end

      def _make_cell_list(*cells)
        hash = {}

        cells.each do |cell|
          if cell.is_a?(Hash)
            cell.each do |key, value|
              if key.is_a?(Array)
                key.each { |k| hash[k] = value }
              else
                hash[key] = value
              end
            end
          elsif cell.is_a?(Array)
            hash.update(_make_cell_list(*cell))
          else
            hash[cell] = :background
          end
        end

        hash
      end

    end
  end
end
