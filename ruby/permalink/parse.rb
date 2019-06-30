require 'uri'

aggregation = {}

CSV.foreach("permalink.csv", headers: true) do |params|
  next if params.strip.empty?

  params.split('&').each { |param| aggregation[param] = 1 }
end
