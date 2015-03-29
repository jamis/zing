require 'mazes/algorithms/base'

module Mazes
  module Algorithms

    class RecursiveDivisionBF < Base
      def initialize(grid, &block)
        super(grid)

        grid.each_cell do |cell|
          cell.neighbors.each do |n|
            cell.link(n, false)
          end
        end

        @regions = [ [0, 0, grid.rows, grid.columns] ]
      end

      def step
        if @regions.empty?
          @done = true
        else
          new_regions = []

          @regions.each do |region|
            new_regions.concat(_divide(*region))
          end

          @regions = new_regions
        end

        !@done
      end

      def _divide(row, column, rows, columns)
        return [] if rows <= 1 && columns <= 1

        if rows > columns
          _divide_horizontally(row, column, rows, columns)
        else
          _divide_vertically(row, column, rows, columns)
        end
      end

      def _divide_horizontally(row, column, rows, columns)
        divide_south_of = rand(rows-1)
        passage_at = rand(columns)

        columns.times do |dx|
          next if passage_at == dx

          cell = @grid[row+divide_south_of, column+dx]
          cell.unlink(cell.s)
        end

        [ [row, column, divide_south_of+1, columns],
          [row+divide_south_of+1, column, rows-divide_south_of-1, columns] ]
      end

      def _divide_vertically(row, column, rows, columns)
        divide_east_of = rand(columns-1)
        passage_at = rand(rows)

        rows.times do |dy|
          next if passage_at == dy

          cell = @grid[row+dy, column+divide_east_of]
          cell.unlink(cell.e)
        end

        [ [row, column, rows, divide_east_of+1],
          [row, column+divide_east_of+1, rows, columns-divide_east_of-1] ]
      end
    end

  end
end

