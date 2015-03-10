require 'mazes/polar_grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid = PolarGrid.new(12)
Algorithms::GrowingTree.on(grid, :last)

grid.render.open
