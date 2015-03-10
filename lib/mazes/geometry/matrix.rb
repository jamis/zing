require 'matrix'

class Vector
  def self.from_sphere(radius, theta, phi)
    x = radius * Math.sin(theta) * Math.cos(phi)
    y = radius * Math.cos(theta)
    z = radius * Math.sin(theta) * Math.sin(phi)

    Vector[x, y, z]
  end
end
