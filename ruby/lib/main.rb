require './tp_framework'

class MiClase
  before_and_after_each_call(
    #Bloque que se ejecuta antes de cada mensaje
   proc { puts "ANTES DEL METODO"},
    #Bloque que se ejecuta después de cada mensaje
   proc { puts "DESPUES DEL METODO"}
  )

  def mensaje_1
    puts "mensaje_1"
    return 5
  end

  def mensaje_2
    puts "mensaje_2"
    return 3
  end
end

objeto = MiClase.new
objeto.mensaje_1
objeto.mensaje_2