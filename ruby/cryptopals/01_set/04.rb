=begin
  Detect single-character XOR

  One of the 60-character strings in this file has been encrypted by
  single-character XOR.

  Find it.

  (Your code from #3 should help.)

  The file is called strings.txt
=end

require_relative '../helpers'

Result = Struct.new(:line, :character, :score, keyword_init: true) do
  def score_sort(other)
    score <=> other.score
  end
end

results = []

File.readlines("04.txt").each do |line|
  line = line.strip
  line_bytes = hex_decode(line)

  max_score = 0
  original_line = ''
  character = ''

  (0..255).each do |xored_candidate|
    xor_result = xor_bytes_against_byte(line_bytes, xored_candidate).pack('C*')
    score = english_score(xor_result)

    if score > max_score
      max_score = score
      original_line = xor_result
      character = xored_candidate
    end
  end

  results << Result.new(line: original_line, character: character.chr, score: max_score)
end

puts results.sort(&:score_sort).last
