require 'mazes/grid'
require 'mazes/polar_grid'
require 'mazes/renderer/spherical'
require 'mazes/geometry/sphere'

module Mazes
  class HemisphereCell < PolarCell
    attr_reader :segment

    def initialize(segment, ring, spoke)
      @segment = segment
      super(ring, spoke)
    end
  end

  class EquatorGrid
    def initialize(id, row, spokes)
      @id = id
      @spokes = spokes
      @grid = Array.new(spokes) { |spoke| HemisphereCell.new(@id, row, spoke) }
      each_cell do |cell|
        cell.cw = @grid[(cell.spoke + 1) % @grid.length]
        cell.ccw = @grid[(cell.spoke - 1) % @grid.length]
      end
    end

    def [](ring, spoke)
      @grid[spoke]
    end

    def widest
      @spokes
    end

    def spokes(ring)
      @spokes
    end

    def random_cell
      @grid.sample
    end

    def each_cell
      @grid.each { |cell| yield cell }
    end
  end

  class HemisphereGrid < PolarGrid
    attr_reader :id

    def initialize(id, rings)
      @id = id
      super(rings)
    end

    def widest
      @grid[-1].length
    end

    def prepare_grid
      grid = Array.new(@rings)
      angular_height = Math::PI / (2 * @rings)

      grid[0] = [ HemisphereCell.new(id, 0, 0) ]

      1.upto(@rings-1) do |ring|
        theta = (ring + 0.5) * angular_height
        radius = Math.sin(theta)
        circumference = 2 * Math::PI * radius

        previous_count = grid[ring - 1].length
        estimated_cell_width = circumference / previous_count
        ratio = (estimated_cell_width / angular_height).round

        cells = previous_count * ratio
        grid[ring] = Array.new(cells) { |spoke| HemisphereCell.new(id, ring, spoke) }
      end

      grid
    end
  end

  class SphereGrid
    attr_reader :rings
    attr_reader :equator

    def initialize(rings)
      @rings = rings
      @equator = rings / 2

      @grid = prepare_grid
      configure_cells
    end

    def prepare_grid
      @grid = []

      @grid << HemisphereGrid.new(@grid.count, @equator)

      if @equator * 2 < @rings
        @grid << EquatorGrid.new(@grid.count, @equator, @grid[0].spokes(@equator-1))
      end

      @grid << HemisphereGrid.new(@grid.count, @equator)
    end

    def configure_cells
      @grid[0].spokes(@equator-1).times do |n|
        a, b = @grid[0][@equator-1, n], @grid[-1][@equator-1, n]

        if @grid.length > 2
          c = @grid[1][0, n]
          a.outward << c
          c.inward = a
          c.outward << b
          b.outward << c
        else
          a.outward << b
          b.outward << a
        end
      end
    end

    def last_segment
      @grid.length-1
    end

    def widest
      @grid[0].widest
    end

    def spokes(segment, ring)
      @grid[segment].spokes(ring)
    end

    def north_pole
      self[0,0,0]
    end

    def south_pole
      self[@grid.length-1, 0, 0]
    end

    def [](segment, ring, spoke)
      @grid[segment][ring, spoke]
    end

    def each_cell
      @grid.each do |segment|
        segment.each_cell { |cell| yield cell }
      end
    end

    def random_cell
      @grid.sample.random_cell
    end

    def render(*args)
      target = "maze"

      target = args.shift if args.first.is_a?(String)
      options = args.shift || {}

      Mazes::Renderer::Spherical.new(self, target, options)
    end

    def geometry(options={})
      Mazes::Geometry::Sphere.new(self, options)
    end

    def longest_path
      first_pass = north_pole.dijkstra.run
      second_pass = first_pass.farthest_cell.dijkstra.run
      second_pass.longest_path
    end
  end
end
