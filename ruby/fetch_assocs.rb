require './config/environment'

output = StringIO.new
output.puts "Model | Relation | Foreign Key"
output.puts "----|----|----"

ActiveRecord::Base.descendants.each do |model|
  next if model.abstract_class?

  model.reflect_on_all_associations.each do |assoc|
    begin
      next unless assoc.klass == Link || model == Link
      output.puts "`#{model.name}` | `#{assoc.name}` | `#{assoc.foreign_key}`"
    rescue ArgumentError, NameError => e
      warn "Could not resolve #{model.name}##{assoc.name} due to #{e}"
    end
  end
end

puts output.string
