# frozen_string_literal: true
# require_relative '../shopify_pay_karafka/application'

module CoreExtensions
  module DateTime
    module BusinessDays
      def utc?
        sleep(1)
        offset == 0
      end
    end
  end
end

# Actually monkey-patch DateTime
DateTime.prepend(CoreExtensions::DateTime::BusinessDays)
time = DateTime.now

Benchmark.ips do |x|
  x.report('master') { time.method(:utc?).super_method.call }
  x.report('patch') { time.method(:utc?).call }

  x.compare!
end
