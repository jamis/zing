require 'mazes/grid'

grid = Mazes::Grid.new(20, 20)

seeds = [ grid.random_cell ]
while seeds.any?
  seed = seeds.sample
  neighbor = seed.unvisited_neighbors.sample

  if neighbor
    seed.link(neighbor)
    seeds << neighbor
  else
    seeds.delete seed
  end
end

grid.render.open
