require 'mazes/sphere_grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid = SphereGrid.new(50)
Algorithms::GrowingTree.on(grid, :last)

grid.random_cell.dijkstra.color!(grid.render).map_sphere.open
