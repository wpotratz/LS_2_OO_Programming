# 

module Speak
  
  def speak(input)
    puts "#{input}"
  end
  
end

class Dog
  attr_accessor :name
  
  def initialize (name)
    @name = name
  end
  
  include Speak
end

class Cat
  attr_accessor :name
  
  def initialize (name)
    @name = name
  end
  
  def name
    "#{@name} is not my name!"
  end
  
  def name
    "#{@name} is my name!"
  end
  
  include Speak
end

sparky = Dog.new('Fido')
sparky.speak "Bow wow"

sprinkles = Cat.new('Whiskers')
sprinkles.speak "Meeeeeow"

puts sprinkles.name
sprinkles.name = "Sprinkles"
puts sprinkles.name



class Student
  GRADE_DEF = {'a' => 5, 'b' => 4, 'c' => 3, 'd' => 2, 'f' => 1}
  
  attr_accessor :age
  
  def initialize(age, grade)
    self.age = age
    @grade = grade
  end

  def better_grade_than?(other_student)
    grade = @grade
    other_grade = other_student.student_grade
    
    if [grade, other_grade].all? { |person_grade| person_grade.class == Fixnum }
      return grade > other_grade
    end
    
    if [grade, other_grade].all? { |person_grade| GRADE_DEF.keys.include?(person_grade) }
      return GRADE_DEF[grade] > GRADE_DEF[other_grade]
    end
    
    false
  end
  
  protected
  
  def student_grade
    @grade
  end
end

wes = Student.new(30, 'a')
lily = Student.new(24, 90)
wes.better_grade_than?(lily)
