require '../lib/main'

class Cat
  before_and_after_each_call(proc { puts 'BEFORE_DE_CAT' }, proc { puts 'AFTER_DE_CAT' })

  def hello_world
    puts "Hello"
  end

  def hello_world_con_nombre(name)
    puts "Hello #{name}"
  end
end

class Pepito
  before_and_after_each_call(proc do puts 'Este es el BEFORE DE PEPITO'
  hola = 3
  puts hola end, proc { puts 'Este es el AFTER DE PEPITO' })

  def hola
    puts "EJECUTANDO METODO HOLA"
  end
end

class ClaseSinBeforeAndAfter
  def chau
    puts "EJECUTANDO METODO CHAU"
  end
end

my_cat = Cat.new
my_cat.hello_world
puts "==========================="
my_cat.hello_world_con_nombre("Paul")
puts "==========================="
Pepito.new.hola
puts "==========================="
ClaseSinBeforeAndAfter.new.chau