require 'mazes/algorithms/base'

module Mazes
  module Algorithms

    class GrowingTree < Base
      def initialize(grid, heuristic=nil, &block)
        super(grid)
        @start = grid.random_cell
        @seeds = [ @start ]
        @heuristic = _build_heuristic(heuristic || block)
        @on_delete = @on_add = ->(seed) {}
      end

      def on_delete(&block)
        @on_delete = block
      end

      def on_add(&block)
        @on_add = block
      end

      def step
        if @seeds.empty?
          @done = true
        else
          seed = @heuristic[ @seeds ]
          unvisited_neighbors = seed.neighbors.select { |n| n.links.empty? }

          if unvisited_neighbors.empty?
            @seeds.delete(seed)
            @on_delete[[seed]]
          else
            neighbor = unvisited_neighbors.sample
            seed.link(neighbor)
            @seeds << neighbor
            @on_add[[seed, neighbor]]
          end
        end

        !@done
      end

      def _random_weights
        weights = {}
        @grid.each_cell { |cell| weights[cell] = rand(100) }
        weights
      end

      def _named_heuristic(name)
        case name
          when :last     then ->(seeds) { seeds.last }
          when :random   then ->(seeds) { seeds.sample }
          when :weighted then
            weights = _random_weights
            ->(seeds) { seeds.sort_by { |a| weights[a] }.last }
          else name
        end
      end

      def _build_heuristic(heuristic)
        if heuristic.is_a?(Array)
          total_weight = 0
          heuristics = heuristic.map do |h|
              if h.is_a?(Array)
                total_weight += h[0]
                [ h[0], _named_heuristic(h[1]) ]
              else
                total_weight += 1
                [ 1, _named_heuristic(h) ]
              end
            end

          ->(seeds) do
            target = rand(total_weight)
            heuristic = heuristics.detect do |h|
              if target < h[0]
                true
              else
                target -= h[0]
                false
              end
            end
            heuristic[1][seeds]
          end
        else
          _named_heuristic(heuristic)
        end
      end
    end

  end
end
