require 'mazes/cell'
require 'mazes/renderer/polar'

module Mazes
  class PolarCell < BaseCell
    attr_reader   :ring, :spoke

    attr_accessor :cw, :ccw, :inward
    attr_reader   :outward

    def initialize(ring, spoke)
      @ring, @spoke = ring, spoke
      @outward = []
      super()
    end

    def neighbors
      [cw, ccw, inward, *outward].compact
    end
  end

  class PolarGrid
    attr_reader :rings

    def initialize(rings)
      @rings = rings
      @grid = prepare_grid
      configure_cells
    end

    def prepare_grid
      grid = Array.new(@rings)

      ring_height = 1.0 / @rings
      grid[0] = [ PolarCell.new(0, 0) ]

      1.upto(@rings-1) do |ring|
        radius = ring.to_f / @rings
        circumference = 2 * Math::PI * radius

        previous_count = grid[ring-1].length
        estimated_cell_width = circumference / previous_count
        ratio = (estimated_cell_width / ring_height).round

        cells = previous_count * ratio
        grid[ring] = Array.new(cells) { |spoke| PolarCell.new(ring, spoke) }
      end

      grid
    end

    def configure_cells
      each_cell do |cell|
        if cell.ring > 0
          cell.cw = self[cell.ring, cell.spoke + 1]
          cell.ccw = self[cell.ring, cell.spoke - 1]

          ratio = @grid[cell.ring].length / @grid[cell.ring - 1].length
          parent = @grid[cell.ring - 1][cell.spoke / ratio]

          parent.outward << cell
          cell.inward = parent
        end
      end
    end

    def [](ring, spoke)
      return nil if ring < 0 || ring >= @rings
      @grid[ring][spoke % @grid[ring].count]
    end

    def origin
      self[0, 0]
    end

    def spokes(ring)
      @grid[ring].count
    end

    def random_cell
      ring = rand(@rings)
      spoke = rand(@grid[ring].length)
      @grid[ring][spoke]
    end

    def each_ring
      @grid.each { |ring| yield ring }
    end

    def each_cell(randomized: false)
      if randomized
        @grid.flatten.shuffle.each { |cell| yield cell }
      else
        each_ring do |ring|
          ring.each { |cell| yield cell }
        end
      end

      self
    end

    def render(*args)
      @renderer ||= begin
        target = "maze"

        target = args.shift if args.first.is_a?(String)
        options = args.shift || {}

        Mazes::Renderer::Polar.new(self, target, options)
      end
    end
  end
end
