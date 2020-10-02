require '../../../ruby/lib/implementaciones/framework'

class Operaciones
  #precondición de dividir
  pre { divisor != 0 }
  #postcondición de dividir
  post { |result| result * divisor == dividendo }
  def dividir(dividendo, divisor)
    dividendo / divisor
  end

  # este método no se ve afectado por ninguna pre/post condición
  def restar(minuendo, sustraendo)
    minuendo - sustraendo
  end
end

#Operaciones.new.dividir(4, 2)

# Se rompe porque no se pude dividir por 0, no cumple precondicion
begin
  respuesta = Operaciones.new.dividir(4, 0)
  puts respuesta
rescue RuntimeError => re
  puts re
end

# Funciona ok!
begin
  respuesta = Operaciones.new.dividir(4, 2)
  puts "El resultado de 4 / 2 = #{respuesta}"
rescue RuntimeError => re
  puts re
end

# Prueba con resta, todo ok

respuesta = Operaciones.new.restar(5,3)
puts "El resultado de 5 - 3 = #{respuesta}"