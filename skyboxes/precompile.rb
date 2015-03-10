require 'oily_png'

ARGV.each do |name|
  puts "compiling #{name}"

  img = ChunkyPNG::Image.from_file(name)
  width = img.width
  height = img.height
  raw = Marshal.dump([width, height, *img.to_rgba_stream.each_byte.to_a])

  output = File.basename(name, ".png") + ".raw"
  File.open(output, "w") { |f| f.write raw }
end
