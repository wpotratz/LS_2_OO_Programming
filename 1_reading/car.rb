require 'pry'

class Vehicle
  @@vehicles_built = 0

  attr_accessor :color
  attr_reader :model, :year

  def initialize(year, color, model)
    @create_ts = Time.now()
    @@vehicles_built += 1
    @year = year.to_i
    self.color = color
    @model = model
  end

  def towable?
    "This vehicle cannot tow :("
  end

  def self.how_many_vehicles?
    "There have been #{@@vehicles_built} vehicle(s) built."
  end

  def spray_paint(new_color)
    self.color = new_color
    puts "You painted your #{model} #{color}!"
  end
  
  def how_old_am_i?
    "This vehicle is #{vehicle_age} year#{'s' unless vehicle_age == 1} old."
  end
  
  private
  
  def vehicle_age
    (Time.now().year - @create_ts.year)
  end
end

module Towable
  def towable?
    "This vehicle can tow!"
  end
end

class MyTruck < Vehicle
  include Towable

  TIRE_SIZES = ['truck', 'light-truck']
  @@trucks_built = 0
  
  def initialize(year, color, model)
    super(year, color, model)
    @@trucks_built += 1
  end
  
  def self.how_many_trucks?
    "There have been #{@@trucks_built} truck(s) built."
  end
end

class MyCar < Vehicle
  TIRE_SIZES = ['car']
  @@cars_built = 0
  
  attr_accessor :current_speed

  def initialize(year, color, model)
    super(year, color, model)
    self.current_speed = 0
    @@cars_built += 1
  end
  
  def self.how_many_cars?
    "There have been #{@@cars_built} car(s) built."
  end

  def self.integer?(input)
    /(^\d*\.\d+$|^\d+\.?\d*$)/.match(input.to_s)
  end

  def self.gas_mileage(miles, gallons)
    unless [miles, gallons].all? { |input| MyCar.integer?(input) }
      return "Invalid entry. Make sure miles and gallons are numeric."
    end
    
    mpg = miles.to_f / gallons.to_f
    
    "With #{miles} miles on #{gallons} gallons, you're getting #{mpg.to_i == mpg ? mpg.to_i : mpg.round(1)} mpg."
  end
  
  def to_s
    puts "Your #{color}, #{@year} #{@model}."
  end
  
  def speed_up(amount)
    self.current_speed += amount.to_i
    puts "Your car sped up to #{current_speed}."
  end
  
  def slow_down(amount)
    self.current_speed -= amount.to_i
    puts "Your car slowed down to #{current_speed}."
  end
  
  def turn_off
    self.current_speed = 0
    puts "Your car has been shut down."
  end
  
  def car_info
    car_drive_status = if current_speed == 0
                         "stopped"
                       else
                         "driving at #{current_speed} mph"
                       end
                       
    "Your #{color} #{year} #{model} is #{car_drive_status}."
  end
end

car = MyCar.new(2016, 'red', 'VW Bus')
puts car

puts MyCar.gas_mileage(200, 10)

#puts car.how_many_vehicles?
puts Vehicle.how_many_vehicles?
puts MyCar.how_many_cars?

truck = MyTruck.new(2016, 'purple', 'Chevy')
puts MyTruck.how_many_trucks?
puts Vehicle.how_many_vehicles?

puts truck.towable?
puts car.towable?

puts MyTruck.ancestors.to_s + "\n__________"
puts MyCar.ancestors.to_s + "\n__________"
puts Vehicle.ancestors.to_s

puts car.how_old_am_i?