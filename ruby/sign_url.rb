require 'openssl'
require 'base64'
require 'rack/utils'

HMAC_SECRET = "super_secret".freeze

def sign_message(message)
  digest = OpenSSL::Digest.new('sha256')
  OpenSSL::HMAC.hexdigest(digest, HMAC_SECRET, message)
end

host =  'my.host.io'
puts "Valid host: #{Base64.urlsafe_encode64(host).sub(/=+\z/, '')}"
puts "Valid hmac: #{sign_message(host)}"
