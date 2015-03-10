require 'fileutils'
require 'oily_png'
require 'mazes/screen_utilities'

module Mazes
  module Renderer

    class Base
      include ScreenUtilities

      attr_reader :image
      attr_reader :target
      attr_reader :frame
      attr_reader :height, :width
      attr_reader :last_file_name

      def initialize(target)
        @target = target
        @frame = 0
      end

      def save(target=@target)
        _save_image "%s.png" % target
        self
      end

      def open
        save if !@last_file_name
        if ENV['X_HEADLESS'] != "1"
          system "qlmanage -p #{@last_file_name} &>/dev/null"
        end
        self
      end

      def save_frame
        _save_image("%s-%04d.png" % [@target, @frame], false)
        @frame += 1
        self
      end

      def start!
        _prepare_animation
        save_frame
      end

      def finish
        save_frame
        _build_animation
        self
      end

      def _prepare_animation(pattern="#{@target}-*.png")
        FileUtils.rm Dir[pattern]
      end

      def _build_animation(pattern="#{@target}-*.png", delay=5, delay_last=200)
        sources = Dir[pattern]
        first = sources[0..-2]
        last = sources.last

        @last_file_name = "#{@target}.gif"

        args = [ "-layers OptimizeFrame",
                 "-delay #{delay}",
                 "-loop 0",
                 *first ]

        args.push "-delay #{delay_last}" if delay_last
        args.push last
        args.push @last_file_name

        system "convert #{args.join(' ')}"
        _cache
      end

      def compare_with(renderer, as: "maze")
        require 'mazes/renderer/compare'
        Mazes::Renderer::Compare.new(as, self, renderer)
      end

      def map_sphere(target="sphere")
        require 'mazes/renderer/pov_sphere'
        Mazes::Renderer::POVSphere.new(target, self)
      end

      def _save_image(name, cache=true)
        @image.save(name)
        @last_file_name = name
        _cache if cache
      end

      def _cache(name=@last_file_name)
        if ENV["X_CACHE_KEY"]
          FileUtils.mkdir_p "cache"
          ext = File.extname(name)
          FileUtils.cp name, "cache/#{ENV['X_CACHE_KEY']}#{ext}"
        end
      end
    end

  end
end
