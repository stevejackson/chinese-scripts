# parses a file with columns separated by tabs, such as
#
# ruby get-column-from-anki-export.rb file.txt 1
#
# blah\t中文\tchinese\n
# and removes all columns except the specified column, so it'd leave:
#
# 中文\n
#

filename = ARGV[0]
save_tab = ARGV[1].to_i

puts save_tab

new_file = ''

File.open(filename, 'r').each do |line|
  columns = line.split("\t")
  new_file << columns[save_tab] << "\n" if columns[save_tab] && columns[save_tab].strip != ''
end

puts new_file.inspect

File.open(filename, 'w') do |file|
  file.puts new_file
end
