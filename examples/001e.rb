require 'mazes/grid'

grid = Mazes::Grid.new(40, 80)

grid.each_cell do |cell|
  neighbor = [*[cell.s]*5, cell.w].compact.sample
  cell.link(neighbor) if neighbor
end

grid.render.open
