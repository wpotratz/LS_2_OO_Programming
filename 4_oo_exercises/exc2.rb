require 'pry'

#module Moveable
#  attr_accessor :speed, :heading
#  attr_writer :fuel_efficiency, :fuel_capacity
#
#  def range
#    @fuel_capacity * @fuel_efficiency
#  end
#end

class Vehicle
  attr_accessor :speed, :heading
  attr_writer :fuel_efficiency, :fuel_capacity

  def initialize(km_traveled_per_liter, liters_of_fuel_capacity)
    self.fuel_efficiency = km_traveled_per_liter
    self.fuel_capacity = liters_of_fuel_capacity
  end

  def range
    @fuel_capacity * @fuel_efficiency
  end
end

class WheeledVehicle < Vehicle
  def initialize(tire_array, km_traveled_per_liter, liters_of_fuel_capacity)
    @tires = tire_array
    super(km_traveled_per_liter, liters_of_fuel_capacity)
  end

  def tire_pressure(tire_index)
    @tires[tire_index]
  end

  def inflate_tire(tire_index, pressure)
    @tires[tire_index] = pressure
  end
end

class Auto < WheeledVehicle
  def initialize
    # 4 tires are various tire pressures
    super([30,30,32,32], 50, 25.0)
  end
end

class Motorcycle < WheeledVehicle
  def initialize
    # 2 tires are various tire pressures along with
    super([20,20], 80, 8.0)
  end
end

class Boat < Vehicle
  attr_accessor :propeller_count, :hull_count

  def initialize(num_propellers, num_hulls, km_traveled_per_liter, liters_of_fuel_capacity)
    self.propeller_count = num_propellers
    self.hull_count = num_hulls
    super(km_traveled_per_liter, liters_of_fuel_capacity)
    # ... code omitted ...
  end
  
  def range
    range_by_using_fuel = super

    range_by_using_fuel + 10
  end
end

class Moterboat < Boat
  def initialize(km_traveled_per_liter, liters_of_fuel_capacity)
    super(1, 1, km_traveled_per_liter, liters_of_fuel_capacity)
  end
end

class Catamaran < Boat
  def initialize(num_propellers, num_hulls, km_traveled_per_liter, liters_of_fuel_capacity)
    super
  end
end

cat_boat = Catamaran.new(2, 2, 60, 40)
p cat_boat
puts cat_boat.range

mot_boat = Moterboat.new(50,35)
p mot_boat
puts mot_boat.range

car = Auto.new
p car
puts car.range
puts car.tire_pressure(1)