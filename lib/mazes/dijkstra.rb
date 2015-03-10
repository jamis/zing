module Mazes
  class Dijkstra
    attr_reader :root
    attr_reader :frontier
    attr_reader :farthest_cell, :greatest_distance

    def self.run(root, options={})
      new(root, options).run
    end

    def initialize(root, colors: 0xff0000ff..0x200000ff)
      @root = root.is_a?(Array) ? root : [ root ]
      @colors = colors
      @frontier = @root
      @distances = @root.inject({}) { |h,k| h.update k => 0 }
      @farthest_cell = nil
      @greatest_distance = 0
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

      lo_r = (@colors.begin & 0xff000000) >> 24
      lo_g = (@colors.begin & 0x00ff0000) >> 16
      lo_b = (@colors.begin & 0x0000ff00) >> 8
      hi_r = (@colors.end & 0xff000000) >> 24
      hi_g = (@colors.end & 0x00ff0000) >> 16
      hi_b = (@colors.end & 0x0000ff00) >> 8

      dr = hi_r - lo_r
      dg = hi_g - lo_g
      db = hi_b - lo_b

      denom = (@greatest_distance > 0 ? @greatest_distance : 1).to_f
      0.upto(@greatest_distance) do |distance|
        t = distance / denom

        r = lo_r + (t * dr).round
        g = lo_g + (t * dg).round
        b = lo_b + (t * db).round

        set[distance] = (r << 24) + (g << 16) + (b << 8) + 0xff
      end

      set
    end

  end
end
