require 'mazes/grid'
require 'mazes/algorithms/binary_tree'

include Mazes

grid = Grid.new(10, 10)
grid.render.start!

algo = Algorithms::BinaryTree.new(grid)
while algo.step
  grid.render.snapshot! algo.current => :highlight, algo.neighbor => :highlight
end

grid.render.finish.open
