# Question 1
require 'pry'

class Pet
  def speak
    "Hello, I'm a pet."
  end

  def run
    'running!'
  end

  def jump
    'jumping!'
  end
end

class Cat < Pet
  def speak
    "Meoooooow"
  end
end

class Dog < Pet
  def speak
    'bark!'
  end
  
  def swim
    'swimming!'
  end
  
  def fetch
    'fetching!'
  end
end

class Bulldog < Dog
  def swim
    "Can't swim!!!"
  end
end

class Person
  attr_accessor :name, :pets

  def initialize(name)
    @name = name
    @pets = []
  end
end


teddy = Dog.new
roosevelt = Cat.new

wes = Person.new('Wes')

wes.pets << teddy
wes.pets << roosevelt

binding.pry
p wes.pets
p wes
puts wes