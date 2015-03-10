require 'mazes/algorithms/base'

module Mazes
  module Algorithms

    class BinaryTree < Base
      attr_reader :current
      attr_reader :neighbor

      def initialize(grid, pair: [:n, :e], ordering: nil)# {{{
        super(grid)
        @cells = @grid.enum_for(:each_cell, randomized: (ordering == :random))
        @pair = pair
      end# }}}

      def step# {{{
        @current = @cells.next

        process_current_step

        true
      rescue StopIteration
        @done = true
        false
      end# }}}

      def process_current_step
        @neighbor = @pair.map { |d| @current.send(d) }.compact.sample
        @current.link(@neighbor) if @neighbor
      end
    end

  end
end
