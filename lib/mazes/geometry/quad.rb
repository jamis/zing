require 'mazes/geometry/matrix'

module Mazes
  module Geometry

    class Quad
      attr_reader :color
      attr_reader :normal
      attr_reader :p1, :p2, :p3, :p4

      def initialize(p1, p2, p3, p4, color=nil)
        @p1, @p2, @p3, @p4 = p1, p2, p3, p4
        @normal = (@p2 - @p1).cross_product(@p3 - @p1).normalize
        @color = color
      end

      def rewind!
        @p1, @p2, @p3, @p4 = @p4, @p3, @p2, @p1
        @normal = (@p2 - @p1).cross_product(@p3 - @p1).normalize
        self
      end

      def each_point
        [@p1, @p2, @p3, @p4].each { |p| yield p }
      end
    end

  end
end
