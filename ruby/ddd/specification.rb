class Specification
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def is_satisfied_by(object)
    true
  end
end

class CompositeSpecification < Specification
  attr_reader :name, :specifications

  def initialize(name)
    super(name)
    @specifications = []
  end

  def add_specification(specification)
    specifications << specification
  end

  def is_satisfied_by(object)
    specifications.inject(true) do |state, specification|
      state && specification.is_satisfied_by(object)
    end
  end
end

class SpecificationA < Specification
  def initialize
    super 'Specification A'
  end

  def is_satisfied_by(object)
    false
  end
end

class SpecificationB < Specification
  def initialize
    super 'Specification B'
  end

  def is_satisfied_by(object)
    true
  end
end

super_specification = CompositeSpecification.new('Super!')
super_specification.add_specification(SpecificationA.new)
super_specification.add_specification(SpecificationB.new)

p super_specification.is_satisfied_by(true)
