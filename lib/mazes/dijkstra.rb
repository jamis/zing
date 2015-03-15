require 'mazes/gradient'

module Mazes
  class Dijkstra
    attr_reader :root
    attr_reader :frontier, :colors
    attr_reader :farthest_cell, :greatest_distance

    def self.run(root, options={})
      new(root, options).run
    end

    def initialize(root, colors: 0xff0000ff..0x200000ff)
      @root = root.is_a?(Array) ? root : [ root ]
      self.colors = colors
      @frontier = @root
      @distances = @root.inject({}) { |h,k| h.update k => 0 }
      @farthest_cell = nil
      @greatest_distance = 0
    end

    def colors=(colors)
      @colors = case colors
        when Range then Gradient.from_range(colors)
        when Array then Gradient.from_points(colors)
        else colors
      end
    end

    def [](cell)
      @distances[cell]
    end

    def color!(renderer)
      run.color(renderer)
    end

    def color(renderer)
      renderer.colors.update(self.color_set)

      renderer.grid.each_cell do |cell|
        renderer.redraw(cell, self[cell])
      end

      renderer
    end

    def run
      while step; end
      self
    end

    def longest_path
      path_to(farthest_cell)
    end

    def path_to(goal)
      path = [goal]
      while !@root.include?(path.last)
        next_cell = path.last.links.min { |a,b| self[a] <=> self[b] }
        path.push next_cell
      end
      path.reverse
    end

    def step
      return false if @frontier.empty?
      new_frontier = []

      @frontier.each do |cell|
        cell.links.each do |link|
          next if @distances[link]

          new_frontier << link
          @distances[link] = @distances[cell] + 1

          if @distances[link] > @greatest_distance
            @greatest_distance = @distances[link]
            @farthest_cell = link
          end
        end
      end

      @frontier = new_frontier
      true
    end

    def color_set
      set = {}

      denom = (@greatest_distance > 0 ? @greatest_distance : 1).to_f
      0.upto(@greatest_distance) do |distance|
        t = distance / denom
        color = colors[t]

        r = (255 * color[:r]).to_i
        g = (255 * color[:g]).to_i
        b = (255 * color[:b]).to_i
        a = (255 * color[:a]).to_i

        set[distance] = (r << 24) + (g << 16) + (b << 8) + a
      end

      set
    end

  end
end
