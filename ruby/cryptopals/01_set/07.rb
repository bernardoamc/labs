require_relative '../helpers'
require 'openssl'

KEY = "YELLOW SUBMARINE"
input = base64_decode(File.read('07.txt').strip)

output = aes_ecb_decrypt(input, KEY.unpack('C*'))
puts output.pack('C*')
