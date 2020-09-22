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