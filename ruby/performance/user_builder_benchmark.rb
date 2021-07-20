# frozen_string_literal: true
#
def encrypt_and_sign(data)
  ShopifyPayEncryptor.encrypt_and_sign(data)
end

def decrypt_and_verify(data)
  ShopifyPayEncryptor.decrypt_and_verify(data)
end

def user_params
  {
    parsed: true,
    email: "#{SecureRandom.hex}@gmail.com",
    mobile_phone_e164: '+15146863347',
    shipping_method: 'free-shipping',
    session_token: encrypt_and_sign('ABC-123'),
    checkout_token: 'my-checkout-token',
    external_account_identifier: 123,
    shop_id: 45,
    shop_permanent_domain: 'shop1.myshopify.io',
    paid_with_shopify_pay: false,
    source: 'somewhere',
    billing_address_attributes: {
      fields: {
        first_name: 'Foo',
        last_name: 'Bar',
        address1: "123 sesam's street",
        address2: 'app 123',
        zip: 'H0H0H0',
        city: 'Montreal',
        country: 'Canada',
        province: 'Quebec',
        phone: '+15145551234',
        company: 'shopify',
      },
    },
    shipping_address_attributes: {
      fields: {
        first_name: 'Foo',
        last_name: 'Bar',
        address1: "123 sesam's street",
        address2: 'app 123',
        zip: 'H0H0H0',
        city: 'Montreal',
        country: 'Canada',
        province: 'Quebec',
        phone: '+15145551234',
        company: 'shopify',
      },
    },
    credit_card_attributes: credit_card_attributes,
    api_client: {
      id: 1234,
      handle: 'something',
    },
  }
end

def credit_card_attributes
  {
    first_name: 'Foo',
    last_name: 'Bar',
    brand: 'visa',
    month: 10,
    year: 30,
    last_digits: 1234,
    payment_token: encrypt_and_sign('west-1234567890'),
  }
end

Benchmark.ips do |x|
  x.report('master') { UserBuilderUncached.new(user_params).build }
  x.report('patch') { UserBuilder.new(user_params).build }

  x.compare!
end
