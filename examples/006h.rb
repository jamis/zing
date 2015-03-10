require 'mazes/sphere_grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid = SphereGrid.new(10)
Algorithms::GrowingTree.on(grid, :last)

grid.geometry(wall_height: 0.1).fly! do
  skybox :thick_clouds
  path grid.north_pole.path_to(grid.south_pole)
end
