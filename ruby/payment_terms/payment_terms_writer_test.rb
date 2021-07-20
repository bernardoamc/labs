require 'minitest/autorun'
require_relative 'payment_terms_writer.rb'

class PaymentTermsWriterTest < Minitest::Test
  def test_product_forms_are_recognized
    input = <<~LIQUID
      {% form 'product', product %}
        Simple form
      {% endform %}

      {% form 'product', product, data-productid: product.id, class: 'addtocartForm' %}
        Complex form
      {% endform %}

      {%- form 'product', product -%}
        Simple form with whitespace control
      {% endform %}

      {%- form 'product', product, data-productid: product.id, class: 'addtocartForm' -%}
        Complex form with whitespace control
      {% endform %}

      <div>
        {% form 'product', product %}
          Form with identation
        {% endform %}
      </div>
    LIQUID

    expected_matches = [
      {
        form: "{% form 'product', product %}",
        offset: [0, 29],
        identation: 0,
      },
      {
        form: "{% form 'product', product, data-productid: product.id, class: 'addtocartForm' %}",
        offset: [59, 140],
        identation: 0,
      },
      {
        form: "{%- form 'product', product -%}",
        offset: [171, 202],
        identation: 0,
      },
      {
        form: "{%- form 'product', product, data-productid: product.id, class: 'addtocartForm' -%}",
        offset: [256, 339],
        identation: 0,
      },
      {
        form: "  {% form 'product', product %}",
        offset: [400, 431],
        identation: 2,
      },
    ]

    matches = []

    output = PaymentTermsWriter.new(input).traverse do |form|
      matches << { form: form.string, offset: form.offset, identation: form.identation_len }
    end

    assert_equal(input, output)
    assert_equal(expected_matches, matches)
  end

  def test_non_product_forms_are_ignored
    input = <<~LIQUID
      {% form 'login', product %}
        Simple login form
      {% endform %}

      <div>
        Fake form
        form 'product', product
      </div>

      { form 'product' %}
        Incorrectly opened form
      {% endform %}

      {% form 'product' }
        Incorrectly closed form
      {% endform %}
    LIQUID

    output = PaymentTermsWriter.new(input).traverse do |form|
      refute(form, message: "Unexpected form: #{form.inspect}")
    end

    assert_equal(input, output)
  end

  def test_payment_terms_tag_is_written
    input = <<~LIQUID
      {% form 'product', product %}
        Simple form
      {% endform %}

      {% form 'product', product, data-productid: product.id, class: 'addtocartForm' %}
        Complex form
      {% endform %}

      {%- form 'product', product -%}
        Simple form with whitespace control
      {% endform %}

      {%- form 'product', product, data-productid: product.id, class: 'addtocartForm' -%}
        Complex form with whitespace control
      {% endform %}

      <div>
        {% form 'product', product %}
          Form with identation
        {% endform %}
      </div>
    LIQUID

    expected_output = <<~LIQUID
      {% form 'product', product %}
        {{ form | payment_terms }}
        Simple form
      {% endform %}

      {% form 'product', product, data-productid: product.id, class: 'addtocartForm' %}
        {{ form | payment_terms }}
        Complex form
      {% endform %}

      {%- form 'product', product -%}
        {{ form | payment_terms }}
        Simple form with whitespace control
      {% endform %}

      {%- form 'product', product, data-productid: product.id, class: 'addtocartForm' -%}
        {{ form | payment_terms }}
        Complex form with whitespace control
      {% endform %}

      <div>
        {% form 'product', product %}
          {{ form | payment_terms }}
          Form with identation
        {% endform %}
      </div>
    LIQUID

    output = PaymentTermsWriter.new(input).traverse do |form|
      form.rewrite
    end

    assert_equal(expected_output, output)
  end
end
