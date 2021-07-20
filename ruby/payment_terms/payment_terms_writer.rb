# frozen_string_literal: true

class PaymentTermsWriter
  PRODUCT_FORM_TAG = %r|
    (?<identation>[[:blank:]]*) # Capture identation before tag
    {%-?                        # Start template
    \s+                         # Match any number of spaces
    form                        # Match form tag
    \s+                         # Match any number of spaces
    ['"]product['"]             # Match product form
    (?:                         # Start of non-capturing group
      (?!%})                    # If "%}" is not present
      .                         # Match any character
    )*?                         # Repeat in a non-greedy manner
    -?%}                        # End template
  |ix

  PAYMENT_TERMS_TAG = /{{\s+form\s+\|\s+payment_terms\s+}}/i

  def initialize(contents)
    # @contents = AnyToUTF8.to_utf8(contents)
    @contents = contents
  end

  class MatchedForm
    IDENTATION_SIZE = 2
    PAYMENT_TERMS_TAG_LITERAL = '{{ form | payment_terms }}'

    attr_reader :string, :identation_len, :offset, :rewritten_string

    def initialize(string:, identation_len:, offset:)
      @string = string
      @identation_len = identation_len
      @offset = offset
      @rewritten_string = nil
    end

    def rewritten?
      !@rewritten_string.nil?
    end

    def rewrite
      new_identation = " " * (identation_len + IDENTATION_SIZE)
      @rewritten_string = string + "\n" + new_identation + PAYMENT_TERMS_TAG_LITERAL
    end
  end

  def traverse
    return @contents if @contents.match?(PAYMENT_TERMS_TAG)

    rewritten_forms = []

    @contents.scan(PRODUCT_FORM_TAG) do
      match = Regexp.last_match
      matched_form = MatchedForm.new(string: match[0], identation_len: match[:identation].length, offset: match.offset(0))

      yield matched_form

      rewritten_forms << matched_form if matched_form.rewritten?
    end

    rewritten_forms.empty? ? @contents : rewrite(rewritten_forms)
  end

  private

  def rewrite(rewritten_forms)
    output = String.new(capacity: @contents.length)
    cursor = 0

    rewritten_forms.each do |form|
      offset_start, offset_end = form.offset
      output += @contents[cursor...offset_start]
      output += form.rewritten_string
      cursor = offset_end
    end

    if cursor != @contents.length
      output += @contents[cursor..-1]
    end

    output
  end
end
