require '../lib/main'

# Pruebas de invariantes
class Estudiante

  attr_accessor :anotadas, :aprobadas

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
santi = Estudiante.new(42,4)
puts santi.aprobadas
puts santi.anotadas
santi.aprobar # Acá revienta porque no cumple con los invariantes!