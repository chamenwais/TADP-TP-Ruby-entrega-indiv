require_relative 'implementaciones/framework'

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

class Cat
  def maullar_con_delay()
    "Miau, a mi me agregaron despues"
  end
end

class Dog
  before_and_after_each_call(proc { puts 'Another before' }, proc { puts 'Another after' })
  def say_guau
    "Guau!"
  end
end

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

class Guerrero
  attr_accessor :vida , :fuerza
  invariant { vida >= 0 }
  invariant { fuerza > 0 && fuerza < 100 }

  def atacar(otro)
    otro.vida -= fuerza
    puts "la vida del otro es #{otro.vida}"
    fuerza
  end
end

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

class Pila
  attr_accessor :current_node, :capacity
  invariant { capacity >= 0 }
  post { empty? }
  def initialize(capacity)
    @capacity = capacity
    @current_node = nil
  end
  pre { !full? }
  post { height > 0 }
  def push(element)
    @current_node = Node.new(element, current_node)
  end
  pre { !empty? }
  def pop
    element = top
    @current_node = @current_node.next_node
    element
  end
  pre { !empty? }
  def top
    current_node.element
  end
  def height
    empty? ? 0 : current_node.size
  end
  def empty?
    current_node.nil?
  end
  def full?
    height == capacity
  end
  Node = Struct.new(:element, :next_node) do
    def size
      next_node.nil? ? 1 : 1 + next_node.size
    end
  end
end

class Cliente
  attr_accessor :nombre
  attr_accessor :saldo
  invariant { saldo >= 0 }
  invariant do
    comprar(10)
    saldo >= 0
  end

  def initialize(_nombre='Senior X',_saldo=50)
    @nombre=_nombre
    @saldo=_saldo
  end

  def comprar(monto)
    @saldo-=monto
  end
end

