# frozen_string_literal: true
unused_routes = {}

# Iterating over all non-empty routes from RouteSet
Rails.application.routes.routes.map(&:requirements).reject(&:empty?).each do |route|
  next unless route.key?(:controller)
  name = route[:controller].camelcase
  next if name.start_with?('Rails')

  controller = "#{name}Controller"

  next unless Object.const_defined?(controller) && !controller.constantize.new.respond_to?(route[:action])
  # Get route for which associated action is not present and add it in final results
  unless Dir.glob(Rails.root.join('app', 'views', name.downcase, "#{route[:action]}.*")).any?
    unused_routes[controller] = [] if unused_routes[controller].nil?
    unused_routes[controller] << route[:action]
  end
end

puts unused_routes
