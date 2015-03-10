require 'opengl'
require 'glu'
require 'glut'

require 'mazes/path'
require 'mazes/screen_utilities'
require 'mazes/skybox'

module Mazes

  class FlyThroughWindow
    include ScreenUtilities
    include Gl, Glu, Glut

    def initialize(geometry)
      total_width, total_height = _screen_size

      @width = (total_width * 0.9).to_i
      @height = (total_height * 0.9).to_i

      pos_x = (total_width - @width) / 2
      pos_y = (total_height - @height) / 2

      @paused = false
      @skybox = nil

      @mode = :none

      @position = [0, 0, 3]
      @up       = [0, 1, 0]
      @look_at  = [0, 0, 0]

      glutInit
      glutInitDisplayMode GLUT_RGB | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH
      glutInitWindowSize @width, @height
      glutInitWindowPosition pos_x, pos_y

      @window = glutCreateWindow "Fly Free, Little Maze!"
      @active_keys = {}

      glutIdleFunc      :_idle
      glutKeyboardFunc  :_normal_keys
      glutSpecialFunc   :_special_key_down
      glutSpecialUpFunc :_special_key_up
      glutReshapeFunc   :_reshape
      glutDisplayFunc   :_redraw

      glClearColor 0.0, 0.0, 0.0, 0
      glClearDepth 1.0
      glDepthFunc GL_LEQUAL
      glEnable GL_DEPTH_TEST
      glEnable GL_LIGHTING
      glEnable GL_LIGHT0
      glEnable GL_LIGHT1
      glEnable GL_COLOR_MATERIAL
      glEnable GL_CULL_FACE
      glEnable GL_RESCALE_NORMAL
      glShadeModel GL_SMOOTH

      glMatrixMode GL_PROJECTION
      glLoadIdentity
      gluPerspective 45.0, @width.to_f / @height, 0.1, 1000.0

      @geometry = geometry
      _prepare_geometry

      glMatrixMode GL_MODELVIEW
    end

    def run
      glutMainLoop
    end

    def skybox(name)
      @skybox = Skybox.new(File.join("skyboxes", name.to_s))
    end

    def rotate(options={y:0.5})
      @mode = :rotation
      @rotation = [0, 0, 0]
      @speed = [options[:x] || 0,
                options[:y] || 0,
                options[:z] || 0]
    end

    def path(cells)
      @mode = :path

      midpoint = ->(cell) do
        m = _metrics_for(cell)
        Vector.from_sphere(1, m[:center][0], m[:center][1])
      end

      controls = []

      cells.each_with_index do |current_cell, index|
        previous_cell = index > 0 ? cells[index-1] : nil
        next_cell     = cells[index+1]
        m             = _metrics_for(current_cell)

        wants_midpoint = previous_cell.nil? ||
          next_cell.nil? ||
          previous_cell.inward == next_cell.inward

        if wants_midpoint
          controls.push midpoint[current_cell].normalize
        end

        if next_cell
          p1 = midpoint[current_cell]
          p2 = midpoint[next_cell]

          p = (p1 + (p2 - p1) * 0.5).normalize
          controls.push p
        end
      end

      @path = Mazes::Path.new(controls)
      @path.eye_level = 1 + @geometry.wall_height / 2
      @t = @path.start

      _compute_path_position
    end

    def swoop!
      @path.prepend @path[0] * 1.5
      @path.prepend @path[0] * 2.5
      @path.prepend @path[0] * 5
      @path.intro_cutoff = 3

      _compute_path_position
    end

    def _metrics_for(cell)
      if cell.ring == 0
        { center: [cell.segment == 0 ? 0 : Math::PI, 0] }
      else
        @geometry.metrics[cell]
      end
    end

    def _idle
      unless @paused
        send :"_idle_when_#{@mode}"
        glutPostRedisplay
      end
    end

    def _idle_when_none
    end

    def _idle_when_rotation
      @rotation[0] += @speed[0]
      @rotation[1] += @speed[1]
      @rotation[2] += @speed[2]
    end

    def _idle_when_path
      @t += 0.025
      @t = @path.finish if @t > @path.finish
      _compute_path_position
    end

    def _compute_path_position
      look_ahead = 0.75

      @position = @path.at(@t)
      @up       = @position.normalize
      @look_at  = @path.at(@t + look_ahead)

      @axis = @rotation = nil

      if @t < @path.intro_cutoff
        dt = @t / @path.intro_cutoff
        landing = @path.at(@path.intro_cutoff)
        look_at = @path.at(@path.intro_cutoff + look_ahead)
        vector = (look_at - landing).normalize
        @look_at = landing + vector * (dt + 0.01)
        @axis = @up.cross_product(@look_at).normalize
        skewed_up = @axis.normalize
        @up = (1 - dt) * skewed_up + dt * @up
        @rotation = -(1 - dt) * 120
      end
    end

    def _normal_keys(key, x, y)
      if key == ?\e
        glutDestroyWindow @window
        exit 0
      elsif key == "p"
        @paused = !@paused
      elsif key == " "
        send(:"_reset_when_#{@mode}")
      end
    end

    def _reset_when_none
    end

    def _reset_when_rotation
      @rotation = [0, 0, 0]
    end

    def _reset_when_path
      @t = 0
      _compute_path_position
    end

    def _special_key_down(key, x, y)
      @active_keys[key] = true
    end

    def _special_key_up(key, x, y)
      @active_keys.delete(key)
    end

    def _reshape(width, height)
      height = 1 if height == 0
      @width, @height = width, height

      glViewport 0, 0, @width, @height

      glMatrixMode GL_PROJECTION
      glLoadIdentity
      gluPerspective 45.0, @width.to_f/@height, 0.1, 500.0

      glMatrixMode GL_MODELVIEW
    end

    def _redraw
      glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
      glLoadIdentity

      glScalef 10, 10, 10
      gluLookAt(@position[0], @position[1], @position[2],
                @look_at[0], @look_at[1], @look_at[2],
                @up[0], @up[1], @up[2])
      @skybox.draw_at(@position) if @skybox

      glLight GL_LIGHT0, GL_AMBIENT, [0.2, 0.2, 0.2, 1.0]
      glLight GL_LIGHT0, GL_DIFFUSE, [1.0, 1.0, 1.0, 1.0]
      glLight GL_LIGHT0, GL_POSITION, [0.0, 10.0, 0.0]

      glLight GL_LIGHT1, GL_AMBIENT, [0.0, 0.0, 0.0, 1.0]
      glLight GL_LIGHT1, GL_DIFFUSE, [0.5, 0.5, 0.5, 1.0]
      glLight GL_LIGHT1, GL_POSITION, [0.0, -10.0, 0.0]

      glLightModel GL_LIGHT_MODEL_AMBIENT, [0.4, 0.4, 0.4, 1.0]

      if @mode == :rotation
        glRotatef @rotation[0], 1, 0, 0
        glRotatef @rotation[1], 0, 1, 0
        glRotatef @rotation[2], 0, 0, 1
      elsif @mode == :path && @t < @path.intro_cutoff
        glRotatef -@rotation, @axis[0], @axis[1], @axis[2]
      end

      glColor3f 0.7, 0.7, 0.7
      glutSolidSphere 1, 50, 50

      glColor3f 0.7, 0.7, 0.7
      glDrawArrays GL_QUADS, 0, @vertex_count

      glutSwapBuffers
    end

    def _prepare_geometry
      vertices = []
      normals  = []

      @geometry.quads.each do |quad|
        quad.each_point do |pt|
          vertices.push pt[0]
          vertices.push pt[1]
          vertices.push pt[2]

          normals.push quad.normal[0]
          normals.push quad.normal[1]
          normals.push quad.normal[2]
        end
      end

      @vertex_count = vertices.length / 3
      @vertices = vertices.pack("f*")
      @normals  = normals.pack("f*")

      glEnableClientState GL_VERTEX_ARRAY
      glEnableClientState GL_NORMAL_ARRAY

      glVertexPointer 3, GL_FLOAT, 0, @vertices
      glNormalPointer GL_FLOAT, 0, @normals
    end
  end

end
