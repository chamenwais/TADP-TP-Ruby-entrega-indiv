require '../lib/main'

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

class Estudiante

  attr_accessor :anotadas, :aprobadas

  invariant { anotadas > 3 } #Para ser alumno regular
  invariant { aprobadas > 15 && aprobadas < 43 } #La cantidad de materias de Ing. en Sistemas

  def initialize(_aprobadas,_anotadas)
    @aprobadas = _aprobadas
    @anotadas = _anotadas
    puts "Se ejecuta el constructor"
  end

  def aprobar
    @aprobadas = @aprobadas + 1
    puts "Aprobé"
  end
end

#my_cat = Cat.new
#my_cat.hello_world
#puts "==========================="
#my_cat.hello_world_con_nombre("Paul")
#puts "==========================="
#my_cat.hello_world_con_nombre_y_bloque("Paul",proc { puts "Ejecute bloque" })
#puts "==========================="
#Pepito.new.hola
#puts "==========================="
#ClaseSinBeforeAndAfter.new.chau

santi = Estudiante.new(1000,4)
#santi.aprobar