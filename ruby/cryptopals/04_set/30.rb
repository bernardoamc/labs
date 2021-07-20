require_relative '../md4'
require_relative '../helpers'
require 'openssl'

print 'Right implementation? '
puts MD4.hexdigest('test'.bytes) == OpenSSL::Digest::MD4.hexdigest('test')

PLAINTEXT = 'comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon'.bytes
SUFFIX = ';admin=true'.bytes
KEY = ['potato', 'secret', 'iranoutofideas'].shuffle.first.bytes
MAC = md4_mac(PLAINTEXT, KEY)

def verify(buffer, mac)
  questionable_mac = md4_mac(buffer, KEY)
  puts "user mac: #{questionable_mac}"
  puts "our mac : #{mac}"
  mac == questionable_mac
end

def md4_padding(message_len)
  mask = (1 << 32) - 1
  bit_len = message_len << 3
  padding = [0x80]
  padding << 0 while ((message_len + padding.size) % 64) != 56
  padding + [bit_len & mask, bit_len >> 32].pack('V2').bytes
end

def length_extension(mac, suffix, length)
  abcd = [mac].pack('H*').unpack('V4')
  MD4.hexdigest(suffix, abcd, length)
end

(1..32).each do |key_length|
  puts "testing key length: #{key_length}"
  padding = md4_padding(PLAINTEXT.size + key_length)
  forged_message = PLAINTEXT + padding + SUFFIX
  forged_mac = length_extension(MAC, SUFFIX, key_length + forged_message.size)

  if verify(forged_message, forged_mac)
    puts "Key length: #{key_length}"
    break
  end
end
