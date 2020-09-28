require 'set'

class Class
  def invariant(&condicion)
    if @invariantes.nil?
      @invariantes = []
    end
    @invariantes << condicion
  end

  define_method :verificar_invariantes do |instancia|
    if @invariantes.any? {|condicion| !(instancia.instance_eval(&condicion)) }
      raise RuntimeError
    end
  end
end

class Estudiante

  attr_accessor :anotadas, :aprobadas
  #invariant { anotadas > 3 } #Para ser alumno regular
  #invariant { aprobadas > 15 && aprobadas < 43 } #La cantidad de materias de Ing. en Sistemas

  def initialize(_aprobadas, _anotadas)
    @aprobadas = _aprobadas
    @anotadas = _anotadas
    puts aprobadas
    puts anotadas
    self.class.verificar_invariantes(self)
  end

  def aprobar
    @aprobadas = @aprobadas + 1
    self.class.verificar_invariantes(self)
  end
end

santi = Estudiante.new(16,30)
santi.aprobar
