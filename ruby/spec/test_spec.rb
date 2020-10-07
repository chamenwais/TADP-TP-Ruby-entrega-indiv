# Tests para before_and_after
describe Cat do
  let(:my_cat) { Cat.new }
  describe '#Cat' do
    it 'deberia decir hello' do
      my_cat.hello_world
    end

    it 'deberia decir hello Paul' do
      my_cat.hello_world_con_nombre("Paul")
    end

    it 'deberia decir hello Paul y ejecutar el bloque retornando: Done' do
      preguntar_como_esta = proc { puts "How are you?" }
      expect(my_cat.hello_world_con_nombre_y_bloque("Paul", &preguntar_como_esta)).to eq("Done")
    end

    it 'deberia decir: Miau, a mi me agregaron despues' do
      expect(my_cat.maullar_con_delay()).to eq("Miau, a mi me agregaron despues")
    end
  end
end

describe Dog do
  let(:my_dog) { Dog.new }
  describe '#Dog' do
    it 'deberia ladrar' do
      expect(my_dog.say_guau).to eq("Guau!")
    end
  end
end

# Tests para invariantes
describe Estudiante do
  let(:palmiro) { Estudiante.new(42,4) }
  describe '#Estudiante' do
    it 'deberia fallar porque palmiro ya había terminado la carrera' do
      begin
        palmiro.aprobar
      rescue RuntimeError => re
        error_invariante = re.message
      end
      expect(error_invariante).to eql "Hay un invariante que dejó de cumplirse!"
    end
    it 'deberia fallar porque necesita estar anotado a más de 3 materias' do
      begin
        palmiro.anotadas=3
      rescue RuntimeError => re
        error_invariante = re.message
      end
      expect(error_invariante).to eql "Hay un invariante que dejó de cumplirse!"
    end
  end
end

describe Guerrero do
  let(:arruinado) { Guerrero.new }
  let(:paolo) { Guerrero.new }
  describe '#Guerrero' do
    it 'el arruinado no puede tener vida negativa' do
      begin
        arruinado.vida=-3
      rescue RuntimeError => re
        error_invariante = re.message
      end
      expect(error_invariante).to eql "Hay un invariante que dejó de cumplirse!"
    end
    it 'a paolo no le podemos asignar fuerza porque primero chequea invariante de VIDA y vida no tiene valor aun' do
      begin
        paolo.fuerza=100
      rescue NoMethodError => error
        error_invariante = error.message
      end
      expect(error_invariante).to eql "undefined method `>=' for nil:NilClass"
    end
    it 'el arruinado no puede ni intentar atacar' do
      begin
        arruinado.vida=-3
        arruinado.fuerza=0
        paolo.vida=50
        paolo.fuerza=100
      rescue RuntimeError => re
        error_invariante = re.message
      end
      expect(error_invariante).to eql "Hay un invariante que dejó de cumplirse!"
    end
  end
end

# Tests para Pre y Post
describe Pila do
  describe '#Pila' do
    it 'pila se crea con capacidad negativa' do
      begin
        stack = Pila.new(-1)
      rescue RuntimeError => re
        error_invariante = re.message
      end
      expect(error_invariante).to eql "Hay un invariante que dejó de cumplirse!"
    end
    it 'no se pueden quitar elementos de una pila vacia' do
      begin
        stack = Pila.new(1)
        stack.push "elemento"
        stack.pop # Queda vacía
        stack.pop # Debería fallar en esta línea
      rescue RuntimeError => re
        error_pre = re.message
      end
      expect(error_pre).to eql "No se cumple la precondición para el método pop"
    end
    it 'no se puede tomar el elemento más arriba de una pila vacía' do
      begin
        stack = Pila.new(1)
        stack.top
      rescue RuntimeError => re
        error_pre = re.message
      end
      expect(error_pre).to eql "No se cumple la precondición para el método top"
    end
    it 'no se puede agregar un elemento a una pila llena' do
      begin
        stack = Pila.new(2)
        stack.push("hola")
        stack.push("hola")
        stack.push("hola")
      rescue RuntimeError => re
        error_pre = re.message
      end
      expect(error_pre).to eql "No se cumple la precondición para el método push"
    end
  end
end

describe Operaciones do
  describe '#Operaciones' do
    it 'no se puede dividir por 0' do
      begin
        respuesta = Operaciones.new.dividir(4, 0)
      rescue RuntimeError => re
        error_pre = re.message
      end
      expect(error_pre).to eql "No se cumple la precondición para el método dividir"
    end
    it '4 dividido 2 da como resultado 2' do
      expect(Operaciones.new.dividir(4, 2)).to eql 2
    end
    it '5 menos 3 da como resultado 2' do
      expect(Operaciones.new.restar(5,3)).to eql 2
    end
  end
end

describe Cliente do
  describe '#Cliente' do
    it 'deberia fallar porque saldo es menor que 0' do

      begin
        cliente_pp=Cliente.new("gonza",-20)
      rescue RuntimeError => re
        error_pre = re.message
      end
      expect(error_pre).to eql "Hay un invariante que dejó de cumplirse!"

    end
    it 'Debería no poder comprar porque el saldo le querdaría negativo' do
      begin
        cliente_ss=Cliente.new("santi",9)
      rescue RuntimeError => re
        error_pre = re.message
      end
      expect(error_pre).to eql "Hay un invariante que dejó de cumplirse!"
    end
  end
end