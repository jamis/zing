require 'mazes/algorithms/base'

module Mazes
  module Algorithms

    class Sidewinder < Base
      attr_reader :current
      attr_reader :neighbor

      def initialize(grid)# {{{
        super
        @rows = @grid.enum_for(:each_row)
      end# }}}

      def step# {{{
        process_current_step

        true
      rescue StopIteration
        @done = (@cells == nil)

        if !@done
          @cells = nil
          close_out if @run.any?
          true
        else
          false
        end
      end# }}}

      def process_current_step
        if !@cells
          @run = []
          @cells = @rows.next.each
        end

        if @run.length > 0 && @run.first.row > 0 && rand(2) == 0
          close_out
        else
          @current = @run.last
          @neighbor = @cells.next
          @run << @neighbor
          @current.link(@neighbor) if @current
        end
      end

      def close_out
        @current = @run.sample
        @neighbor = @current.n
        @current.link(@neighbor) if @neighbor
        @run.clear
      end
    end

  end
end
