require '../lib/main'

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

# PRUEBAS
# Hacemos que se rompa el invariante!
begin
  stack = Pila.new(-1)
rescue RuntimeError => re
  puts re
end

# Prueba metodo pop, no pasa la precondición porque la pila ya está vacía!
begin
  stack = Pila.new(1)
  stack.push"elemento"
  stack.pop # Queda vacía
  stack.pop # Debería fallar en esta línea
rescue RuntimeError => re
  puts re
end

# Prueba metodo top (No pasa la precondición porque no hay elementos en la pila!)
begin
  stack = Pila.new(1)
  stack.top
rescue RuntimeError => re
  puts re
end

# Prueba metodo push (Se rompe la precondicion porque ya está llena la pila)
begin
  stack = Pila.new(2)
  stack.push("hola")
  stack.push("hola")
  stack.push("hola")
  puts "ok"
rescue RuntimeError => re
  puts re
end

#Caso feliz
begin
  stack = Pila.new(3)
  stack.push(1)
  stack.push(2)
  puts stack.top
  stack.pop
end
