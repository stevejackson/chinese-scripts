require 'hz2py'

filename = ARGV[0]

i = 0
columns = []
data = []
file = File.open(filename, 'r').each do |line|
  data << line.split(',')
  if i == 0
    columns = line.split(',')
  else

  end
  i += 1
end

data.each do |line|
  puts '-'
  puts line[1]
  line[1] = TraditionalAndSimplified.conv_s2t(line[1]) if line[1]
  puts line[1]
end

File.open(filename, 'w') do |file|
  data.each do |line|
    file.puts line.join(',') if line && line[1] && line[1].strip != ''
  end
end

puts data.inspect
