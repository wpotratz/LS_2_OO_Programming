# Question 1

# bob = Person.new('bob')
# bob.name                  # => 'bob'
# bob.name = 'Robert'
# bob.name                  # => 'Robert'

class Person
  attr_accessor :name
  
  def initialize(name)
    self.name = name
  end
end

puts bob = Person.new('bob')
puts bob.name                  # => 'bob'
puts bob.name = 'Robert'
puts bob.name                  # => 'Robert'

puts "######################################"

# Question 2

# bob = Person.new('Robert')
# bob.name                  # => 'Robert'
# bob.first_name            # => 'Robert'
# bob.last_name             # => ''
# bob.last_name = 'Smith'
# bob.name                  # => 'Robert Smith'

class Person
  attr_accessor :first_name, :last_name
  
  def initialize(first_name, last_name = '')
    self.first_name = first_name
    self.last_name = last_name
    @name = "#{self.first_name} #{self.last_name}"
  end
  
  def name
    @name = "#{self.first_name} #{self.last_name}".strip
  end
  
  def self.compare_names(person1, person2)
    names_are_same = (person1.name.strip.downcase == person2.name.strip.downcase)
    
    "#{person1.name} and #{person2.name}#{' do not' unless names_are_same} have the same name."
  end
  
  def to_s
    name
  end
end

puts bob = Person.new('Robert')
puts bob.name                  # => 'Robert'
puts bob.first_name            # => 'Robert'
puts bob.last_name             # => ''
puts bob.last_name = 'Smith'
puts bob.name                  # => 'Robert Smith' 

puts billy = Person.new('Billy Jean')
puts billy.name
puts "######################################"

# Question 3
#Already added last name checking thing in #2

# Question 4
bob = Person.new('Robert Smith')
rob = Person.new('Robert Smith')
puts Person.compare_names(bob, rob)
puts Person.compare_names(bob, billy)
puts "The person's name is: #{bob}"
# Answer: Add this to the Person class
#def self.compare_names(person1, person2)
#  names_are_same = (person1.name.strip.downcase == person2.name.strip.downcase)
#  
#  "#{person1.name} and #{person2.name} #{'do not' unless names_are_same} have the same name."
#end

