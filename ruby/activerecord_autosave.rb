# frozen_string_literal: true

require "active_record"

conn = { adapter: "sqlite3", database: "checkout_example" }

ActiveRecord::Base.establish_connection(conn)

class Checkout < ActiveRecord::Base
  connection.create_table :checkouts, force: true do |t|
    t.string :email
    t.timestamps
  end

  has_many :credit_cards, autosave: true
end

class CreditCard < ActiveRecord::Base
  connection.create_table :credit_cards, force: true do |t|
    t.belongs_to :checkout
    t.string :number
    t.timestamps
  end

  belongs_to :checkout
end

['credit_cards', 'checkouts'].each do |table_name|
  ActiveRecord::Base.connection.execute("delete from #{table_name}")
  ActiveRecord::Base.connection.execute("DELETE FROM SQLITE_SEQUENCE WHERE name='#{table_name}'")
end

checkout = Checkout.create(email: 'foobar@gmail.com')
CreditCard.create!(checkout: checkout, number: '123')
CreditCard.create!(checkout: checkout, number: '456')
CreditCard.create!(checkout: checkout, number: '789')

ActiveRecord::Base.logger = Logger.new(STDOUT)

new_checkout_instance = Checkout.first
credit_card = new_checkout_instance.credit_cards.last
credit_card.number = '999'
new_checkout_instance.save
