require '../lib/main'

# Pruebas de before_and_after
class Cat
  before_and_after_each_call(proc { puts 'BEFORE_DE_CAT' }, proc { puts 'AFTER_DE_CAT' })

  def hello_world
    puts "Hello"
  end

  def hello_world_con_nombre(name)
    puts "Hello #{name}"
  end

  def hello_world_con_nombre_y_bloque(name, &bloque)
    puts "Hello #{name}"
    bloque.call
    "Done"
  end
end

my_cat = Cat.new
my_cat.hello_world
puts "==========================="
my_cat.hello_world_con_nombre("Paul")
puts "==========================="
my_cat.hello_world_con_nombre_y_bloque("Paul",proc { puts "Ejecute bloque" })
puts "==========================="