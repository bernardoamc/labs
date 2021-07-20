
  class OrderMapper
    def fetch_for_fulfillment(id:)
      datasource_order = DataSource::Order.includes(:line_items).find(id)

      domain_line_items = datasource_order.line_items.map do |line_item|
        Domain::LineItem.new(
          product_id: line_item.product_id,
          price: line_item.price,
          quantity: line_item.quantity
        )
      end

      Domain::Order.new(
        total_price: datasource_order.total_price,
        currency: datasource_order.currency,
        line_items: domain_line_items,
        ...
      )
    end
  end

  class UserMapper
    def fetch_admin(...); Admin.new(...);     end
    def fetch_paid(...);  PaidUser.new(...);  end
    def fetch_trial(...); TrialUser.new(...); end

    def update_admin(domain, attributes); ... end
    def update_paid(domain, attributes);  ... end
    def update_trial(domain, attributes); ... end
  end

  class PaidUserMapper
    def fetch(...); PaidUser.new(...); end
    def update(domain, attributes); end
  end

  class TrialUserMapper
    def fetch(...); TrialUser.new(...); end
    def update(domain, attributes); end
  end

  class TrialUser
    MAXIMUM_FEATURES = 5

    def initialize(id:, email:, created_at:, used_features:)
      @id = id
      @email = email
      @created_at = created_at
      @used_features = used_features
    end

    def trial_expired?
      created_at > 1.month.ago?
    end

    def features_remaining?
      used_features < MAXIMUM_FEATURES
    end
  end


  class User < ApplicationRecord
    has_many :addresses
    has_many :credit_cards
  end

  class Book < ApplicationRecord
    scope :available, where(available: true)
  end

  class Author < ApplicationRecord
    has_many :books
    scope :with_available_books, joins(:books).merge(Book.available)
  end

  # Return all authors with at least one available book:
  Author.with_available_books


  class Repository
    def self.register(type, repo)
      repositories[type] = repo
    end

    def self.repositories
      @repositories ||= {}
    end

    def self.for(type)
      repositories[type]
    end
  end

	module SQLRepository
		class UserRepository
			def mapper_class
				Mappers::User
			end

			def find_by(id:)
				mapper_class.find_by(id)
			end

			def update(domain_object, attributes: {})
				mapper_class.update(domain_object, attributes)
			end

      # Other necessary operations for our domain...
		end
	end

  Repository.register(:user, SQLRepository::UserRepository.new)

  # users_controller.rb
  def show
    @user = Repository.for(:user).find_by(id: params[:id])
  end

