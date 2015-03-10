require 'mazes/sphere_grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid = SphereGrid.new(20)
Algorithms::GrowingTree.on(grid, :last)

grid.geometry.fly! do
  skybox :thick_clouds
  path grid.longest_path
  swoop!
end
