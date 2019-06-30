require 'bundler'
Bundler.require

require 'openssl'
require 'base64'
require 'rack/utils'

HMAC_SECRET = "s3cr3t".freeze

get '/' do
  <<-HTML
    <!doctype html>
    <html>
      <head>
        <title>Create signed URL</title>
      </head>
      <body>
        <form method="POST" action="/signed_url">
          <div>
            <label for="host">Allowed Host</label>
            <input id="host" name="host" value="#{params['host']}"/>
          </div>
          <button type="submit">Submit</button>
        </form>
        <script>
          (function() {
            "use strict";

            var input = document.getElementById("host");

            if (!input.value) {
              input.value = window.location.host;
            }
          })();
        </script>
      </body>
    </html>
  HTML
end

get '/cdn/protected.css' do
  headers['Content-Type'] = 'text/css'

  <<-CSS
    body { background: pink !important; }
  CSS
end

post '/signed_url' do
  signed_url = URI::HTTP.build(
    host: 'localhost',
    path: '/cdn/protected.css',
    port: 4566,
    query: Rack::Utils.build_query(
      host: Base64.urlsafe_encode64(params['host'] || '', padding: false),
      hmac: sign_message(params['host'] || '')
    )
  ).to_s

  <<-HTML
    <!doctype html>
    <html>
      <head>
        <title>Create signed URL</title>
        <link rel="stylesheet" href="#{signed_url}"/>
      </head>
      <body>
        <h1>This page should be pink</h1>
        <pre>#{signed_url}</pre>
      </body>
    </html>
  HTML
end

def sign_message(message)
  digest = OpenSSL::Digest.new('sha256')
  hmac = OpenSSL::HMAC.digest(digest, HMAC_SECRET, message)
  Base64.urlsafe_encode64(hmac, padding: false)
end
