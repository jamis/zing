# Zing!

Zing! is a framework for playful generation of random mazes.

This was taken from the "Twistly Little Passages" presentation at
Mountain West Ruby Conference 2015. The framework is strongly
influenced by the code from the author's book, "Mazes for Programmers",
published by the Pragmatic Programmers:

https://pragprog.com/book/jbmaze/mazes-for-programmers

## Usage

There are *lots and lots* of examples in the `examples` directory. The
basic usage looks something like this:

~~~ruby
require 'mazes/grid'
require 'mazes/algorithms/growing_tree'

rows, columns = 20, 30
grid = Mazes::Grid.new(rows, columns)

Mazes::Algorithms::GrowingTree.on(grid, [:last, :random])
grid.render.open
~~~

The above will generate a 20x30 grid, run the Growing Tree algorithm
with a 50/50 split between choosing the last cell and choosing a
random cell, and then render a PNG image of the resulting maze and
display it.

## Dependencies

The code is currently *very very very heavily* Mac specific. Some functionality simply will not work on anything but a Mac. Pull requests to fix these dependencies are welcome.

Other dependencies:

* ChunkyPNG & OilyPNG (http://chunkypng.com/)
* OpenGL gem (https://rubygems.org/gems/opengl)

## License

Creative Commons Attribution-ShareAlike 4.0 International

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

## Author

Jamis Buck <jamis@jamisbuck.org>

If you like this code, please buy my book, too!

"Mazes for Programmers"
https://pragprog.com/book/jbmaze/mazes-for-programmers
