require 'mazes/polar_grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid1, grid2 = PolarGrid.new(24), PolarGrid.new(24)

Algorithms::GrowingTree.on(grid1, :last)
Algorithms::GrowingTree.on(grid2, :random)

grid1.origin.dijkstra.color!(grid1.render).compare_with(
  grid2.origin.dijkstra.color!(grid2.render)
).open
