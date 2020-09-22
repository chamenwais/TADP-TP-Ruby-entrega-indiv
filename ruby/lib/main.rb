require_relative '../lib/main_helper'

class Cat
  before_and_after_each_call(proc { puts 'before' }, proc { puts 'after' })
  before_and_after_each_call(proc { puts 'before2' }, proc { puts 'after2' })

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




