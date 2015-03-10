require 'mazes/grid'

grid = Mazes::Grid.new(10, 10)

grid.each_cell do |cell|
  neighbor = [cell.n, cell.e].compact.sample
  cell.link(neighbor) if neighbor
end

grid.render.open
