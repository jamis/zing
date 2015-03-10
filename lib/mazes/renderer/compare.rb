require 'mazes/renderer/base'

module Mazes
  module Renderer

    class Compare < Base
      def initialize(target, a, b)
        super target

        max_width = [a.width, b.width].max
        margin = max_width / 10

        @width = a.width + margin + b.width
        @height = [a.height, b.height].max

        @image = ChunkyPNG::Image.new(@width, @height, 0xffffffff)

        a_ofs = (@height - a.height) / 2
        b_ofs = (@height - b.height) / 2

        @image.replace!(a.image, 0, a_ofs)
        @image.replace!(b.image, a.width + margin, b_ofs)
      end
    end

  end
end
