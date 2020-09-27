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
      expect(my_cat.hello_world_con_nombre_y_bloque("Paul", preguntar_como_esta)).to eq("Done")
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

describe Estudiante do
  let(:palmiro) { Estudiante.new }
  describe '#Estudiante' do
    it 'deberia fallar porque palmiro ya había terminado la carrera' do
      expect {palmiro.aprobar}.to raise_error(RuntimeError)
    end
  end
end

describe Guerrero do
  let(:arruinado) { Guerrero.new }
  let(:paolo) { Guerrero.new }
  describe '#Guerrero' do
    it 'el arruinado no puede ni intentar atacar' do
      arruinado.vida=-3
      arruinado.fuerza=0
      expect {arruinado.atacar(Guerrero.new)}.to raise_error(RuntimeError)
    end

    it 'cuando un guerrero lo arruina, ya no puede atacar' do
      arruinado.vida=5
      arruinado.fuerza=3
      paolo.vida=50
      paolo.fuerza=50
      paolo.atacar(arruinado)
      expect {arruinado.atacar(Guerrero.new)}.to raise_error(RuntimeError)
    end
  end
end