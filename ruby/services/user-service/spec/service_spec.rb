require_relative 'spec_helper'

def app
  UserService
end

describe UserService do
  before do
    User.delete_all
  end

  describe "POST on /api/v1/users/:id/sessions" do
    before do
      User.create(name: 'josh', password: 'nyc.rb rules')
    end

    it "should return the user object on valid credentials" do
      post '/api/v1/users/josh/sessions', { password: 'nyc.rb rules' }.to_json

      last_response.status.must_equal 200
      attributes = JSON.parse(last_response.body)
      attributes["name"].must_equal "josh"
    end

    it "should fail on invalid credentials" do
      post '/api/v1/users/josh/sessions', { password: 'wrong' }.to_json

      last_response.status.must_equal 400
    end
  end

  describe "GET on /api/v1/users/:id" do
    before do
      User.create(
        :name => "paul",
        :email => "paul@pauldix.net",
        :password => "strongpass",
        :bio => "rubyist"
      )
    end

    it "should return a user by name" do
      get '/api/v1/users/paul'
      last_response.status.must_equal 200
      attributes = JSON.parse(last_response.body)
      attributes["name"].must_equal "paul"
    end

    it "should return a user with an email" do
      get '/api/v1/users/paul'
      last_response.status.must_equal 200
      attributes = JSON.parse(last_response.body)
      attributes["email"].must_equal "paul@pauldix.net"
    end

    it "should not return a user's password" do
      get '/api/v1/users/paul'
      last_response.status.must_equal 200
      attributes = JSON.parse(last_response.body)
      refute attributes.has_key?("password")
    end

    it "should return a user with a bio" do
      get '/api/v1/users/paul'
      last_response.status.must_equal 200
      attributes = JSON.parse(last_response.body)
      attributes["bio"].must_equal "rubyist"
    end

    it "should return a 404 for a user that doesn't exist" do
      get '/api/v1/users/foo'
      last_response.status.must_equal 404
    end
  end

  describe "POST on /api/v1/users" do
    it "should create a user" do
      post '/api/v1/users', {
        name: 'trotter',
        email: 'no spam',
        password: 'whatever',
        bio: 'southern belle'
      }.to_json

      last_response.status.must_equal 200

      get '/api/v1/users/trotter'

      attributes = JSON.parse(last_response.body)
      attributes['name'].must_equal 'trotter'
      attributes['email'].must_equal 'no spam'
      attributes['bio'].must_equal 'southern belle'
    end
  end

  describe "PUT on /api/v1/users/:id" do
    it "should update a user" do
      User.create(
        name: 'bryan',
        email: 'no spam',
        password: 'whatever',
        bio: 'rspec master'
      )

      put '/api/v1/users/bryan', { bio: 'testing freak' }.to_json
      last_response.status.must_equal 200

      get '/api/v1/users/bryan'
      attributes = JSON.parse(last_response.body)

      attributes['bio'].must_equal 'testing freak'
    end
  end

  describe "DELETE on /api/v1/users/:id" do
    it "should delete a user" do
       User.create(
        name: 'deleteme',
        email: 'deletemail',
        password: 'deldel',
        bio: 'born to be deleted'
      )

      delete '/api/v1/users/deleteme'
      last_response.status.must_equal 200

      get '/api/v1/users/deleteme'
      last_response.status.must_equal 404
    end
  end
end
