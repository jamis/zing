require 'mazes/renderer/base'

module Mazes
  module Renderer

    class POVSphereGeometry < Base
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

        light_source {
          <50, -50, 50>
          color rgb 0.4
        }

        union {
          ##MESH##

          sphere {
            <0,0,0>, 1
          }

          texture {
            pigment { color rgb 1 }
            finish { ambient 0.3 diffuse 0.5 specular 0.2 }
          }

          rotate y*360*clock
          rotate z*30
          rotate -x*30
        }
      ENDPOV

      def initialize(target, geometry)
        super target

        size = _available_size.min
        @width = @height = size

        @geometry = geometry
      end

      def _save_image(name)
        scene = SCENE.gsub(/##MESH##/, _build_mesh)
        File.write "scene.pov", scene
        system "povray +H#{@height} +W#{@width} +A -GA +Iscene.pov +O#{name} &> pov-output.txt"
        @last_file_name = name
        _cache
      end

      def _build_mesh
        mesh = "mesh {\n"

        @geometry.quads.each do |quad|
          mesh << _triangles(quad) << "\n"
        end

        mesh << "}\n"
      end

      def _triangles(quad)
        points = []
        quad.each_point { |p| points << ("<" + p.to_a.join(", ") + ">") }

        "triangle { #{points[0]}, #{points[1]}, #{points[2]} } " +
        "triangle { #{points[0]}, #{points[2]}, #{points[3]} }"
      end
    end

  end
end

