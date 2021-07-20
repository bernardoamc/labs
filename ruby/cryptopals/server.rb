require "sinatra"
require_relative 'helpers'

KEY = ['potato', 'secret', 'iranoutofideas'].shuffle.first.bytes
DELAY = 0.005

set :bind, '0.0.0.0'
set :port, 9999

helpers do
  def unsafe_verify(buffer, provided_mac)
    correct_mac = sha1_hmac(buffer, KEY)
    return false if provided_mac.size != correct_mac.size

    provided_mac.length.times do |i|
      return false if provided_mac[i] != correct_mac[i]
      sleep(DELAY)
    end

    true
  end
end

# http://localhost:9999/?file=abc&signature=potato
get "/" do
  file = params[:file].bytes
  signature = params[:signature]

  if unsafe_verify(file, signature)
    status(200)
  else
    status(500)
  end
end
