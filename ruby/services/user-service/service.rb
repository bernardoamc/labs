ENV['RACK_ENV'] ||= 'development'

require 'bundler'
require 'active_record'
require 'yaml'
Bundler.require :default, ENV['RACK_ENV'].to_sym

databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[ENV["RACK_ENV"] || "development"])

require_relative 'models/user'

if ENV['RACK_ENV'] == 'test'
  puts 'starting in test mode'
  User.destroy_all

  User.create(
    :name => "paul",
    :email => "paul@pauldix.net",
    :bio => "rubyist"
  )

end

endputs "starting in test mode"

class UserService < Sinatra::Base
  post '/api/v1/users/:name/sessions' do
    begin
      attributes = JSON.parse(request.body.read)
      user = User.find_by(name: params[:name], password: attributes['password'])

      if user
        user.to_json
      else
        error 400, { error: 'invalid login credentials' }.to_json
      end
    rescue => e
      error 400, e.message.to_json
    end
  end

  get '/api/v1/users/:name' do
    user = User.find_by_name(params[:name])

    if user
      user.to_json
    else
      error 404, { error: 'user not found' }.to_json
    end
  end

  # Testing with curl
  # curl -X POST -H "Content-Type: application/json" -d '{ "name":"bernardo", "email":"a@b.com", "password":"lala", "bio":"It works!" }' http://localhost:9292/api/v1/users
  post '/api/v1/users' do
    begin
      user_attributes = JSON.parse(request.body.read)
      user = User.create(user_attributes)

      if user.valid?
        user.to_json
      else
        error 400, user.errors.to_json
      end
    rescue => e
      error 400, e.message.to_json
    end
  end

  put '/api/v1/users/:name' do
    user = User.find_by_name(params[:name])

    if user
      begin
        user_attributes = JSON.parse(request.body.read)
        if user.update_attributes(user_attributes)
          user.to_json
        else
          error 400, user.errors.to_json
        end
      rescue => e
        error 400, e.message.to_json
      end
    else
      error 404, { error: 'user not found' }.to_json
    end
  end

  delete '/api/v1/users/:name' do
    user = User.find_by_name(params[:name])

    if user
      user.destroy
      user.to_json
    else
      error 404, { error: 'user not found' }.to_json
    end
  end
end
