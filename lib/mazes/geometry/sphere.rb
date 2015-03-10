require 'mazes/geometry/quad'
require 'mazes/renderer/pov_sphere_geometry'

module Mazes
  module Geometry

    class Sphere
      attr_reader :quads
      attr_reader :metrics
      attr_reader :wall_height

      def initialize(grid, options)
        @grid = grid

        theta_inc    = Math::PI / @grid.rings
        thickness    = (options[:wall_thickness] || 0.05) * theta_inc
        @wall_height = options[:wall_height] || 0.05

        @quads = []
        @metrics = {}

        @grid.each_cell do |cell|
          next if @grid.spokes(cell.segment, cell.ring) < 2

          u       = 1.0 / grid.spokes(cell.segment, cell.ring)
          v       = cell.ring / @grid.rings

          phi_inc = 2 * Math::PI / grid.spokes(cell.segment, cell.ring)
          theta   = cell.ring * theta_inc
          phi     = cell.spoke * phi_inc

          t0 = theta - thickness
          t1 = theta + thickness
          t2 = theta + theta_inc - thickness
          t3 = theta + theta_inc + thickness

          tc = theta + theta_inc / 2
          poleward = theta

          segdt = theta_inc / cell.outward.length
          segt = theta + segdt / 2
          rimward = cell.outward.map { (_, segt = segt, segt+segdt).first }

          p0 = phi - thickness
          p1 = phi + thickness
          p2 = phi + phi_inc - thickness
          p3 = phi + phi_inc + thickness

          pc = phi + phi_inc / 2
          ccw = phi
          cw = phi + phi_inc

          if cell.segment == @grid.last_segment
            t0 = Math::PI - t0
            t1 = Math::PI - t1
            t2 = Math::PI - t2
            t3 = Math::PI - t3
            tc = Math::PI - tc
            poleward = Math::PI - poleward
            rimward.map! { |v| Math::PI - v }
          end

          inner = []
          outer = []

          [t0, t1, t2, t3].each do |t|
            in_row, out_row = [], []

            [p0, p1, p2, p3].each do |p|
              in_row << Vector.from_sphere(1, t, p)
              out_row << Vector.from_sphere(1 + @wall_height, t, p)
            end

            inner << in_row
            outer << out_row
          end

          @metrics[cell] = {
            inner: inner,
            outer: outer,
            center: [tc, pc],
            u: u,
            v: v,
            cw: cw,
            ccw: ccw,
            poleward: poleward,
            rimward: rimward
          }

          q = []
          if !cell.linked?(:cw)
            q << Quad.new(inner[0][2], outer[0][2], outer[0][3], inner[0][3])
            q << Quad.new(inner[0][2], inner[3][2], outer[3][2], outer[0][2])
            q << Quad.new(inner[3][2], inner[3][3], outer[3][3], outer[3][2])
            q << Quad.new(inner[3][3], inner[0][3], outer[0][3], outer[3][3])
            q << Quad.new(outer[3][3], outer[0][3], outer[0][2], outer[3][2])
          end

          if !cell.linked?(:inward)
            q << Quad.new(inner[0][0], outer[0][0], outer[0][3], inner[0][3])
            q << Quad.new(inner[1][3], inner[0][3], outer[0][3], outer[1][3])
            q << Quad.new(inner[1][0], inner[1][3], outer[1][3], outer[1][0])
            q << Quad.new(inner[0][0], inner[1][0], outer[1][0], outer[0][0])
            q << Quad.new(outer[0][0], outer[1][0], outer[1][3], outer[0][3])
          end

          # build geometry for outward wall ONLY for the row that neighbors the last segment
          if cell.segment < @grid.last_segment && cell.outward[0].segment == @grid.last_segment && !cell.linked?(cell.outward[0])
            q << Quad.new(inner[2][0], outer[2][0], outer[2][3], inner[2][3])
            q << Quad.new(inner[3][3], inner[2][3], outer[2][3], outer[3][3])
            q << Quad.new(inner[3][0], inner[3][3], outer[3][3], outer[3][0])
            q << Quad.new(inner[2][0], inner[3][0], outer[3][0], outer[2][0])
            q << Quad.new(outer[2][0], outer[3][0], outer[3][3], outer[2][3])
          end

          q.each { |q| q.rewind! } if cell.segment != @grid.last_segment
          @quads.concat(q)
        end
      end

      def uv2pos(u, v)
        theta = 2 * Math::PI * u
        phi   = Math::PI * v
        Vector.from_sphere(1, theta, phi)
      end

      def render(target='sphere')
        Mazes::Renderer::POVSphereGeometry.new(target, self)
      end

      def fly
        require 'mazes/fly_through_window'
        Mazes::FlyThroughWindow.new(self)
      end

      def fly!(&block)
        window = fly
        window.instance_exec(&block) if block
        window.run
      end

    end

  end
end
