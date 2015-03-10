require 'mazes/cell'
require 'mazes/renderer/orthogonal'

module Mazes
  class Grid
    attr_reader :rows, :columns
    attr_reader :wrap_horizontal, :wrap_vertical

    def initialize(rows, columns, options={})
      @rows = rows
      @columns = columns

      @wrap_horizontal = options[:wrap_horizontal]
      @wrap_vertical   = options[:wrap_vertical]

      @grid = prepare_grid
      configure_cells
    end

    def prepare_grid
      Array.new(@rows) do |row|
        Array.new(@columns) do |column|
          Cell.new(row, column)
        end
      end
    end

    def configure_cells
      each_cell do |cell|
        cell.n = self[cell.row-1, cell.column]
        cell.s = self[cell.row+1, cell.column]
        cell.e = self[cell.row, cell.column+1]
        cell.w = self[cell.row, cell.column-1]
      end
    end

    def [](row, column)
      row = row % @rows if @wrap_vertical
      column = column % @columns if @wrap_horizontal

      return nil if row < 0 || row >= rows
      return nil if column < 0 || column >= columns
      @grid[row][column]
    end

    def random_cell
      @grid[rand(rows)][rand(columns)]
    end

    def size
      rows * columns
    end

    def each_row
      @grid.each { |row| yield row }
      self
    end

    def each_cell(randomized: false)
      if randomized
        @grid.flatten.shuffle.each { |cell| yield cell }
      else
        each_row do |row|
          row.each { |cell| yield cell }
        end
      end

      self
    end

    def tile_set(name)
      tiles = {}

      Dir["tiles/#{name}/*.png"].each do |file|
        key = File.basename(file, ".png").to_sym
        tiles[key] = ChunkyPNG::Image.from_file(file)
      end

      render(tiles: tiles)
    end

    def render(*args)
      @renderer ||= begin
        target = "maze"

        target = args.shift if args.first.is_a?(String)
        options = args.shift || {}

        Mazes::Renderer::Orthogonal.new(self, target, options)
      end
    end

    def longest_path
      first_pass = self[0,0].dijkstra.run
      second_pass = first_pass.farthest_cell.dijkstra.run
      second_pass.longest_path
    end
  end
end
