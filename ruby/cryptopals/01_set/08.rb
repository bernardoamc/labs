require_relative '../helpers'

File.readlines("08.txt").each do |line|
  line_bytes = hex_decode(line.strip)
  chunks = line_bytes.each_slice(16).to_a

  if chunks.size != chunks.uniq.size
    puts "Found: #{hex_encode(line_bytes)}"
  end
end
