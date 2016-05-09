class Greeting
  def greet(message)
    puts message
  end
end

class Hello < Greeting
  def hi
    greet "Hi"
  end
end

class Goodbye < Greeting
  def bye
    greet "Bye bye..."
  end
end

hello = Greeting.new
hello.greet('Hello!')

hi = Hello.new
hi.hi

bye = Goodbye.new
bye.bye