require 'mazes/grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid1, grid2 = Grid.new(80, 80), Grid.new(80, 80)

Algorithms::GrowingTree.on(grid1, :random)
Algorithms::GrowingTree.on(grid2, :last)

grid1.random_cell.dijkstra.color!(grid1.render walls: false).
compare_with(
  grid2.random_cell.dijkstra.color!(grid2.render walls: false)
).open
