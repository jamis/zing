module Mazes
  module Algorithms
    class Base
      def self.on(grid, *args, &block)
        new(grid, *args, &block).run
      end

      def initialize(grid)
        @grid = grid
        @done = false
      end

      def done?
        @done
      end

      def run
        step until done?
        @grid
      end
    end
  end
end
