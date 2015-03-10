module Mazes

  class Skybox
    include Gl, Glu, Glut

    attr_reader :textures

    def initialize(source)
      @textures = {}

      [:back, :front, :up, :down, :left, :right].each do |key|
        @textures[key] = glGenTextures(1).first

        raw = File.read("#{source}/#{key}.raw")
        width, height, *bytes = Marshal.load(raw)

        glBindTexture GL_TEXTURE_2D, @textures[key]
        glTexImage2D GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, bytes
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST
      end
    end

    def draw_at(position)
      glPushMatrix
      glPushAttrib GL_ENABLE_BIT
      glEnable GL_TEXTURE_2D
      glDisable GL_DEPTH_TEST
      glDisable GL_LIGHTING
      glDisable GL_BLEND
      glDisable GL_CULL_FACE

      glColor4f 1, 1, 1, 1
      glTranslatef position[0], position[1], position[2]

      glBindTexture GL_TEXTURE_2D, @textures[:front]
      glBegin GL_QUADS
        glTexCoord2f(0, 1);  glVertex3f( 0.5, -0.5, 0.5)
        glTexCoord2f(1, 1);  glVertex3f(-0.5, -0.5, 0.5)
        glTexCoord2f(1, 0);  glVertex3f(-0.5,  0.5, 0.5)
        glTexCoord2f(0, 0);  glVertex3f( 0.5,  0.5, 0.5)
      glEnd

      glBindTexture GL_TEXTURE_2D, @textures[:back]
      glBegin GL_QUADS
        glTexCoord2f(0, 1);  glVertex3f(-0.5, -0.5, -0.5)
        glTexCoord2f(1, 1);  glVertex3f( 0.5, -0.5, -0.5)
        glTexCoord2f(1, 0);  glVertex3f( 0.5,  0.5, -0.5)
        glTexCoord2f(0, 0);  glVertex3f(-0.5,  0.5, -0.5)
      glEnd

      glBindTexture GL_TEXTURE_2D, @textures[:left]
      glBegin GL_QUADS
        glTexCoord2f(0, 1);  glVertex3f(-0.5, -0.5,  0.5)
        glTexCoord2f(1, 1);  glVertex3f(-0.5, -0.5, -0.5)
        glTexCoord2f(1, 0);  glVertex3f(-0.5,  0.5, -0.5)
        glTexCoord2f(0, 0);  glVertex3f(-0.5,  0.5,  0.5)
      glEnd

      glBindTexture GL_TEXTURE_2D, @textures[:right]
      glBegin GL_QUADS
        glTexCoord2f(0, 1);  glVertex3f( 0.5, -0.5, -0.5)
        glTexCoord2f(1, 1);  glVertex3f( 0.5, -0.5,  0.5)
        glTexCoord2f(1, 0);  glVertex3f( 0.5,  0.5,  0.5)
        glTexCoord2f(0, 0);  glVertex3f( 0.5,  0.5, -0.5)
      glEnd

      glBindTexture GL_TEXTURE_2D, @textures[:up]
      glBegin GL_QUADS
        glTexCoord2f(0, 0);  glVertex3f( 0.5,  0.5, -0.5)
        glTexCoord2f(0, 1);  glVertex3f( 0.5,  0.5,  0.5)
        glTexCoord2f(1, 1);  glVertex3f(-0.5,  0.5,  0.5)
        glTexCoord2f(1, 0);  glVertex3f(-0.5,  0.5, -0.5)
      glEnd

      glBindTexture GL_TEXTURE_2D, @textures[:down]
      glBegin GL_QUADS
        glTexCoord2f(1, 1);  glVertex3f(-0.5, -0.5, -0.5)
        glTexCoord2f(1, 0);  glVertex3f(-0.5, -0.5,  0.5)
        glTexCoord2f(0, 0);  glVertex3f( 0.5, -0.5,  0.5)
        glTexCoord2f(0, 1);  glVertex3f( 0.5, -0.5, -0.5)
      glEnd

      glPopAttrib
      glPopMatrix
    end
  end

end
