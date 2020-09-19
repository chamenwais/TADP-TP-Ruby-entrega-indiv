class Module
  def before_and_after_each_call(blockBefore, blockAfter)
    if self.singleton_class.instance_variable_get(:@procsBefore).nil?
     self.singleton_class.instance_variable_set(:@procsBefore, [])
    end

    if self.singleton_class.instance_variable_get(:@procsAfter).nil?
      self.singleton_class.instance_variable_set(:@procsAfter, [])
    end

    self.singleton_class.instance_variable_get(:@procsBefore) << blockBefore
    self.singleton_class.instance_variable_get(:@procsAfter) << blockAfter
  end
end

module AntesYDespues

  def initialize
    self.interceptarMetodos
    super
  end

  def callProcsAfter
    self.class.singleton_class.instance_variable_get(:@procsAfter).each do |procAfter|
      procAfter.call
    end
  end

  def callProcsBefore
    self.class.singleton_class.instance_variable_get(:@procsBefore).each do |procBefore|
      procBefore.call
    end
  end

  def getAuxMethodSymbol(metodo)
    ("@@" + (metodo.to_s) + "Aux").to_sym
  end

  def notNilAndNotEmpty(parametros)
    !parametros.nil? and !parametros.empty?
  end

  def getClassVariableOfSelfClass(metodo)
    self.class.class_variable_get(getAuxMethodSymbol(metodo)).bind(self.class.new)
  end

  def interceptarMetodos
    self.class.instance_methods(false).each do |metodo|
      unbound_method = self.class.instance_method(metodo)
      losParametros = unbound_method.parameters[0]
      self.class.class_variable_set(getAuxMethodSymbol(metodo), unbound_method)
      if notNilAndNotEmpty(losParametros)
        self.define_singleton_method(metodo) { |*parametros|
          callProcsBefore
          retorno = getClassVariableOfSelfClass(metodo).call(*parametros)
          callProcsAfter
          retorno
        }
      else
        self.define_singleton_method(metodo) {
          callProcsBefore
          retorno = getClassVariableOfSelfClass(metodo).call
          callProcsAfter
          retorno
        }
      end
    end
  end
end

class Class
  include AntesYDespues
end

class Prueba
  attr_accessor :numeroDePrueba

  def initialize(numeroDePrueba=1)
    self.numeroDePrueba=numeroDePrueba
  end

  before_and_after_each_call(proc{ puts "Entre primero a un mensaje" },proc{ puts "Sali primero de un mensaje" })
  def materia
    puts "materia"
    :tadp
  end
  before_and_after_each_call(proc{ puts "Entre segundo a un mensaje" },proc{ puts "Sali segundo de un mensaje" })
  def anio
    2020
  end

  def notaPromo(anio, limite)
    if anio < 2016
      4
    elsif anio > 2016 and limite < 2021
      6
    else
      0
    end
  end
end

class Prueba
  def agregadoDespues
    "anda!"
  end
end

