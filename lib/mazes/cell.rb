require 'mazes/dijkstra'

module Mazes
  class BaseCell
    def initialize
      @links = {}
    end

    def neighbors
      raise NotImplementedError
    end

    def unvisited_neighbors
      neighbors.select { |n| n.links.empty? }
    end

    def link(cell, reciprocate=true)
      @links[cell] = true
      cell.link(self, false) if reciprocate
    end

    def unlink(cell, reciprocate=true)
      @links.delete(cell)
      cell.unlink(self, false) if reciprocate
    end

    def linked?(cell)
      cell = send(cell) if cell.is_a?(Symbol)
      @links[cell]
    end

    def links
      @links.keys
    end

    def dijkstra(options={})
      Mazes::Dijkstra.new(self, options)
    end

    def path_to(cell)
      dijkstra.run.path_to(cell)
    end
  end

  class Cell < BaseCell
    attr_accessor :n, :s, :e, :w
    attr_reader :row, :column

    def initialize(row, column)
      @row, @column = row, column
      super()
    end

    def neighbors
      [n, s, e, w].compact
    end

    def inspect
      "#<Cell #{row},#{column}>"
    end
  end
end
