require 'mazes/grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid = Grid.new(10, 10)
Algorithms::GrowingTree.on(grid, :weighted)

grid.render.start!
dijkstra = grid.random_cell.dijkstra

while dijkstra.step
  dijkstra.color(grid.render).save_frame
end

grid.render.finish.open
