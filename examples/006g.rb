require 'mazes/sphere_grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid = SphereGrid.new(40)
Algorithms::GrowingTree.on(grid, :last)

grid.geometry(wall_thickness: 0.2).fly! do
  rotate y:0.5, x:1
  skybox :thick_clouds
end
