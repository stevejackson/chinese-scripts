# encoding: UTF-8
# Parse a given file for its vocabulary
#
# ruby parse.rb [input book text to parse for new words] [known vocab list] [new words CSV]

require 'rmmseg'
require 'zidian'
require 'ruby-pinyin'

RMMSeg::Dictionary.load_dictionaries

def clean_text(text)
  # get rid of chinese punctuation
  text = text.gsub(/《|》|，|。|？|：|！|……|——|、/, '')

  # get rid of english punctuation
  text = text.gsub(/,|-|!|\.|\s|<|>|\?|:/, '')

  # get rid of ascii stuff that sometimes hangs around in utf-8 files
  text = text.force_encoding('UTF-8').gsub(/　/, '')

  text.gsub(/\n/, '')
end

def create_word_array(text)
  algor = RMMSeg::Algorithm.new(text)
  word_results = []
  loop do
    tok = algor.next_token
    break if tok.nil?
    word_results << tok.text.strip.force_encoding('utf-8') if tok.text.strip != ''
  end

  word_results_2 = word_results.inject(Hash.new(0)) {|h,i| h[i] += 1; h }
  word_results = word_results_2.sort_by { |key, value| value }
  #word_results.uniq
end 

def ignore_word?(word)
  ignored_characters = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '千', '万', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '零']
  ignore_word = true

  word[0].strip.each_char do |char|
    if !ignored_characters.include? char
      ignore_word = false
      break
    end
  end

  ignore_word
end

book_filename = ARGV[0]
known_vocab_filename = ARGV[1]
new_words_filename = ARGV[2]
puts "Parsing #{book_filename}"

file_text = File.open(book_filename, "r").read
file_text = clean_text(file_text)

book_words = create_word_array(file_text)

puts ''
puts "#{book_filename} has #{book_words.count} words."

known_words = []
File.open(known_vocab_filename, 'r').each do |line|
  line = clean_text(line)
  known_words << line.strip
end
known_words.uniq!

puts ""
puts "#{known_vocab_filename} has #{known_words.count} already known vocab words."
puts ""

# Compare what's unique between the two word lists
new_words = []
book_words.each_with_index do |word, i|
  if i % 1000 == 0
    puts "Comparing at index #{i}..."
  end
  next if known_words.include?(word[0])
  next if ignore_word?(word[0])
  new_words << word
end

puts "#{new_words.count} new words found."

result_data = []

# 汉字,pinyin,english definition
new_words.each_with_index do |x, i| 
  if i % 100 == 0
    puts "Compiling new words definitions CSV at index #{i}..."
  end

  next if !x || x[0].strip == ''
  next if x[1] <= 1

  pinyin = PinYin.of_string(x[0], true).join(' ')
  next if !pinyin || pinyin.strip == ''
  pinyin.downcase!

  definition = Zidian.find(x[0])
  next if !definition || !definition.first || !definition.first.english
  definition = definition.first.english.join(' / ')

  result_data << [x[0], pinyin, definition, x[1]]
end

File.open(new_words_filename, 'w') do |file|
  result_data.each do |line|
    file.puts line.join("\t")
  end
end

puts "New words written to #{new_words_filename}. #{result_data.count} results written with definitions found."
