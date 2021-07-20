require_relative '../helpers'
require_relative '../sha1'
require 'digest/sha1'

buffer = 'test'
original = Digest::SHA1.new.hexdigest(buffer)
ruby_implementation = SHA1.hexdigest(buffer.bytes)

raise 'Wrong implementation' if original != ruby_implementation

KEY = 'potato'.bytes
PLAINTEXT = base64_decode('"WW91ciBndWVzcyBpcyBnb29kIGFzIG15IGd1ZXNz"')
MAC = sha1_mac(PLAINTEXT, KEY)

def verify(buffer, mac)
  mac == sha1_mac(buffer, KEY)
end

def mutated_mac(mac)
  mutated = mac.clone
  index = rand(0...mutated.size)
  mutated[index] = (mutated[index].ord ^ 1).chr
  mutated
end

def mutated_plaintext(plaintext)
  mutated = plaintext.clone
  index = rand(0...mutated.size)
  mutated[index] ^= 1
  mutated
end

puts verify(PLAINTEXT, MAC)
puts !verify(mutated_plaintext(PLAINTEXT), MAC)
puts !verify(PLAINTEXT, mutated_mac(MAC))
