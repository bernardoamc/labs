require_relative '../helpers'

puts pkcs7_unpad(
  "ICE ICE BABY\x04\x04\x04\x04".unpack('C*')
).pack('C*')

begin
  puts pkcs7_unpad(
    "ICE ICE BABY\x05\x05\x05\x05".unpack('C*')
  ).pack('C*')
rescue
  puts 'Invalid padding'
end

begin
  puts pkcs7_unpad(
    "ICE ICE BABY\x01\x02\x03\x04".unpack('C*')
  ).pack('C*')
rescue
  puts 'Invalid padding'
end
