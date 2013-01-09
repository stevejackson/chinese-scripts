
require 'zidian'

def chinese_to_english(word)
  results = Zidian.find(word)
  if results && results.first
    return results.first.english.join(' / ')
  end
  nil
end

puts chinese_to_english('hey')
