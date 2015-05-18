class User < ActiveRecord::Base
  validates :name, :email, uniqueness: true

  def to_json
    super(except: :password)
  end
end
