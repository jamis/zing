require 'mazes/grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid1, grid2 = Grid.new(20, 20), Grid.new(20, 20)

Algorithms::GrowingTree.on(grid1, :random)
Algorithms::GrowingTree.on(grid2, :last)

grid1.random_cell.dijkstra.color!(grid1.render).
compare_with(
  grid2.random_cell.dijkstra.color!(grid2.render)
).open
