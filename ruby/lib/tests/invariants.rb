require '../../../ruby/lib/implementaciones/framework'

# Pruebas de invariantes
class Estudiante

  attr_accessor :anotadas, :aprobadas

  before_and_after_each_call(proc {puts "Before estudiante"}, proc { puts "After estudiante "})
  invariant { anotadas > 3 } #Para ser alumno regular
  invariant { aprobadas > 15 && aprobadas < 43 } #La cantidad de materias de Ing. en Sistemas

  def initialize(_aprobadas,_anotadas)
    @aprobadas = _aprobadas
    @anotadas = _anotadas
  end

  def aprobar
    @aprobadas = @aprobadas + 1
  end
end

class Guerrero
  attr_accessor :vida, :fuerza

  invariant { vida >= 0 }
  invariant { fuerza > 0 && fuerza < 100 }
  def atacar(otro)
    otro.vida -= fuerza
  end
end

# Pruebas con Guerrero
arruinado=Guerrero.new
paolo=Guerrero.new
puts paolo.class.instance_methods(false).include? :vida=
paolo.fuerza = 0 # Se rompe porque el invariant analiza VIDA y es null.
paolo.vida = 3 # Se rompe porque el invariant analiza FUERZA y es null.

# Pruebas con Estudiante
santi = Estudiante.new(42,4)
santi.aprobadas = 1000

puts santi.aprobadas
puts santi.anotadas
santi.aprobar # Acá revienta porque no cumple con los invariantes!

