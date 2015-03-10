require 'mazes/grid'
require 'mazes/algorithms/growing_tree'

include Mazes

grid = Grid.new(10, 10)
grid.render.start!

algo = Algorithms::GrowingTree.new(grid, :random)
algo.on_add { |seeds| grid.render.update! seeds => :highlight }
algo.on_delete { |seeds| grid.render.update! seeds }

algo.run

grid.render.finish.open
