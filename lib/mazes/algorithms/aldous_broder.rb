require 'mazes/algorithms/base'

module Mazes
  module Algorithms

    class AldousBroder < Base
      attr_reader :current
      attr_reader :neighbor

      def initialize(grid)# {{{
        super
        @current = @grid.random_cell
        @remaining = @grid.size-1
      end# }}}

      def step
        neighbor = current.neighbors.sample
        @neighbor = nil

        unless neighbor.links.any?
          @remaining -= 1
          current.link(neighbor)
          @neighbor = current
        end

        @current = neighbor

        @remaining > 0
      end
    end

  end
end
