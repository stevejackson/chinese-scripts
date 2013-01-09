# encoding: utf-8

# inputs a CSV of chinese vocabulary, given the column of 汉字。
# it will determine if the traditional/simplified version of the word is different.
# the words with differences will be output to the output CSV.

# example: ruby find-simp-trad-differences.rb hsk.csv hsk-differences.csv 1               "t"
#                                             [input] [output]            [hanzi column]  [destination "t" or "s"]

require 'hz2py'
require 'csv'

input_filename = ARGV[0]
output_filename = ARGV[1]
hanzi_column = ARGV[2].to_i
destination_type = ARGV[3]

different_columns = []

original_count = 0

File.open(input_filename).each_line do |input_line|
  input_line = input_line.force_encoding('utf-8')
  input_line.gsub!('"', "\'")

  CSV.parse(input_line, :col_sep => "\t") do |columns|
    hanzi = columns[hanzi_column]
    next if hanzi.nil?

    result = case destination_type
    when 't'
      TraditionalAndSimplified.conv_s2t(hanzi)
    when 's'
      TraditionalAndSimplified.conv_t2s(hanzi)
    else
      ''
    end

    hanzi.strip!
    result.strip!

    if hanzi && result && hanzi != '' && result != '' && hanzi != result
      columns[0] = result
      different_columns << columns

      puts ''
      puts "Found difference:"
      puts "Original: #{hanzi}"
      puts "Result:  #{result}"
    end
  end

  original_count += 1
end

puts "Original count: #{original_count}"
puts "Difference count: #{different_columns.count}"

CSV.open(output_filename, "wb") do |csv|
  different_columns.each do |line|
    csv << line
  end
end