require 'mazes/sphere_grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid = SphereGrid.new(20)
Algorithms::GrowingTree.on(grid, :last)

grid.render.map_sphere.open
