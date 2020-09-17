def initializeProcsBefore
  begin
    self.class_variable_get(:@@procsBefore)
  rescue
    self.class_variable_set(:@@procsBefore, [])
  end
end

def initializeProcsAfter
  begin
    self.class_variable_get(:@@procsAfter)
  rescue
    self.class_variable_set(:@@procsAfter, [])
  end
end

def before_and_after_each_call(blockBefore, blockAfter)
  initializeProcsBefore
  initializeProcsAfter

  self.class_variable_get(:@@procsBefore) << blockBefore
  self.class_variable_get(:@@procsAfter) << blockAfter
end

class Prueba

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

def callProcsAfter
  Prueba.class_variable_get(:@@procsAfter).each do |procAfter|
    procAfter.call
  end
end

def callProcsBefore
  Prueba.class_variable_get(:@@procsBefore).each do |procBefore|
    procBefore.call
  end
end

def getAuxMethodSymbol(metodo)
  ("@@" + (metodo.to_s) + "Aux").to_sym
end

def notNilAndNotEmpty
  !@parametros.nil? and !@parametros.empty?
end

def getClassVariableOfPrueba(metodo)
  Prueba.class_variable_get(getAuxMethodSymbol(metodo))
      .bind(Prueba.new)
end

Prueba.instance_methods(false).each do |metodo|
  @parametros=Prueba.instance_method(metodo).parameters[0]
  Prueba.class_variable_set(getAuxMethodSymbol(metodo), Prueba.instance_method(metodo))
  if notNilAndNotEmpty
    Prueba.send(:define_method, metodo){ |*parametros|
      callProcsBefore
      @retorno=getClassVariableOfPrueba(metodo).call(*parametros)
      callProcsAfter
      @retorno
    }
  else
    Prueba.send(:define_method, metodo){
      callProcsBefore
      @retorno= getClassVariableOfPrueba(metodo).call
      callProcsAfter
      @retorno
    }
  end
end