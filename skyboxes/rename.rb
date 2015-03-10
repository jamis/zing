require 'fileutils'

ARGV.each do |name|
  ext = name[/\.(\w+)$/, 1]
  if name =~ /_bk|Back/
    FileUtils.mv(name, "back.#{ext}")
  elsif name =~ /_ft|Front/
    FileUtils.mv(name, "front.#{ext}")
  elsif name =~ /_lf|Left/
    FileUtils.mv(name, "left.#{ext}")
  elsif name =~ /_rt|Right/
    FileUtils.mv(name, "right.#{ext}")
  elsif name =~ /_up|Up/
    FileUtils.mv(name, "up.#{ext}")
  elsif name =~ /_dn|Down/
    FileUtils.mv(name, "down.#{ext}")
  else
    puts "unknown #{name}"
  end
end
