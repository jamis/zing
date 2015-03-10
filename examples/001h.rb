require 'mazes/grid'

grid = Mazes::Grid.new(40, 80)

grid.each_cell do |cell|
  s = cell.column + 1
  w = grid.columns - cell.column
  neighbor = [*[cell.s]*s, *[cell.w]*w].compact.sample
  cell.link(neighbor) if neighbor
end

grid.render(inset: 0.1).open
