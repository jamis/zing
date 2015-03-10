require 'mazes/renderer/base'

module Mazes
  module Renderer

    class POVSphere < Base
      SCENE = <<-ENDPOV
        background { rgb 1 }

        camera {
          right x
          location <0,0,-2.5>
          look_at  <0,0,0>
        }

        light_source {
          <-50, 50, -50>
          color rgb 1
        }

        sphere {
          <0,0,0>, 1
          texture {
            pigment {
              image_map {
                png "##MAP##"
                map_type 1
              }
            }
            finish { ambient 0.3 diffuse 0.5 specular 0.2 }
          }

          rotate y*360*clock
          rotate z*30
          rotate -x*30
        }
      ENDPOV

      def initialize(target, texture)
        super target

        size = _available_size.min
        @width = @height = size

        @texture = texture
      end

      def rotate(frames=24)
        last_clock = (frames - 1) / frames.to_f
        pattern = "#{@target}[0-9]*.png"
        _prepare_animation pattern
        name = "%s.png" % @target
        args = ["+KFF#{frames}", "+KF#{last_clock}"]
        _pov name, *args
        _build_animation pattern, 10, nil
        self
      end

      def _save_image(name, cache=true)
        _pov name
        _cache if cache
      end

      def _pov(name, *args)
        @texture.save unless @texture.last_file_name
        scene = SCENE.gsub(/##MAP##/, @texture.last_file_name)
        File.write "scene.pov", scene
        real_args = ["+H#{@height}", "+W#{@width}", "+A", "-GA",
          "+Iscene.pov", "+O#{name}", *args]
        system "povray #{real_args.join(' ')} &> pov-output.txt"
        @last_file_name = name
      end
    end

  end
end
