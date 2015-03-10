module Mazes

  class Path
    attr_accessor :eye_level
    attr_accessor :intro_cutoff

    def initialize(controls)
      @controls = controls
      @eye_level = 1.0
      @intro_cutoff = 0.0
    end

    def finish
      @controls.length - 1
    end

    def start
      0
    end

    def prepend(control)
      @controls.unshift(control)
    end

    def append(control)
      @controls.push(control)
    end

    def count
      @controls.length
    end

    def [](n)
      @controls[n]
    end

    def at(real_t)
      n = real_t.floor
      n = 0 if n < 0
      n = @controls.length - 1 if n >= @controls.length

      t = real_t - n
      t = 1.0 if t > 1.0

      start = @controls[n]
      finish = @controls[n+1] || @controls[n]

      if real_t < @intro_cutoff
        n = (start + (finish - start) * t)
        n2 = n.normalize * @eye_level
        n2.magnitude > n.magnitude ? n2 : n
      else
        (start + (finish - start) * t).normalize * @eye_level
      end
    end
  end

end
