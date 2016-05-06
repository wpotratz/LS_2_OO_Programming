class Animal
  attr_accessor :name
  
  def initialize(name)
    self.name = name
  end
end
  
module Swimmable
  def swim
    "I'm swimming!"
  end
end

class Mammal < Animal
  def speak
    puts "Hello"
  end
end

class Whale < Mammal
  include Swimmable
  
  def speak
    super + ". I'm a whale!"
  end
end

class Cat < Mammal
end

my_whale = Whale.new("Harry")
puts my_whale.swim
puts my_whale.name
puts my_whale.speak

my_cat = Cat.new("Whiskers")
puts my_cat.name
puts my_cat.speak
puts my_cat.swim