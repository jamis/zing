module Mazes

  class Gradient
    def self.rgb_for(value)
      case value
      when Integer then
        { r: ((value >> 24) & 0xFF)/255.0,
          g: ((value >> 16) & 0xFF)/255.0,
          b: ((value >>  8) & 0xFF)/255.0,
          a: (value & 0xFF)/255.0 }
      when Hash then
        value
      when Array then
        { r: value[0], g: value[1], b: value[2], a: value[3] || 1.0 }
      when String then
        value = value[1..-1] if value =~ /^#/
        rgb_for(value.to_i(16))
      else
        raise NotImplementedError, "rgb_for(#{value.inspect})"
      end
    end

    def self.from_range(range)
      from_points(range.begin, range.end)
    end

    def self.from_points(*points)
      gradient = new

      gradient[0] = rgb_for(points.first)
      gradient[1] = rgb_for(points.last)

      if points.length > 2
        inc = 1.0 / (points.length - 1)
        points[1..-2].each_with_index do |point, i|
          gradient[(i+1) * inc] = rgb_for(point)
        end
      end

      gradient
    end

    def initialize
      @steps = []
      @sorted = nil
    end

    def []=(t, rgb)
      rgb = self.class.rgb_for(rgb)
      @steps << { t: t, r: rgb[:r], g: rgb[:g], b: rgb[:b], a: rgb[:a] }
      @sorted = nil
      rgb
    end

    def [](t)
      _make_sorted_list!
      @sorted.each_with_index do |rgb, i|
        if rgb[:t] >= t
          lo = @sorted[i-1]
          hi = rgb

          interp = (t - lo[:t]) / (hi[:t] - lo[:t])
          rdiff  = hi[:r] - lo[:r]
          gdiff  = hi[:g] - lo[:g]
          bdiff  = hi[:b] - lo[:b]
          adiff  = hi[:a] - lo[:a]

          return { r: (lo[:r] + interp * rdiff),
                   g: (lo[:g] + interp * gdiff),
                   b: (lo[:b] + interp * bdiff),
                   a: (lo[:a] + interp * adiff) }
        end
      end

      { r: 0, g: 0, b: 0, a: 0 }
    end

    def _make_sorted_list!
      @sorted ||= begin
        list = @steps.dup
        list = [ { t: 0, r: 0, g: 0, b: 0 } ] if list.empty?
        list = list.sort { |a,b| a[:t] <=> b[:t] }
        list.unshift [ { t:0, r:0, g:0, b:0, a:0 } ] if list.first[:t] > 0.0
        list.push [ { t:1, r:1, g:1, b:1, a:1 } ] if list.last[:t] < 1.0
        list
      end
    end

  end

end
