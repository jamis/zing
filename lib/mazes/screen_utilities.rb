module Mazes
  module ScreenUtilities
    def _screen_size
      if ENV['X_SCREEN_SIZE']
        width, height = ENV['X_SCREEN_SIZE'].split(/x/)
      else
        width, height = `system_profiler SPDisplaysDataType`.match(/Resolution: (\d+) x (\d+)/)[1, 2]
      end

      [width.to_i, height.to_i]
    end

    def _available_size
      width, height = _screen_size

      width = width * 0.8
      height = height * 0.8

      [width.to_i, height.to_i]
    end
  end
end
