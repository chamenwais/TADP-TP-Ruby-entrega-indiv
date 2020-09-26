describe Cat do
  let(:gatito) { Cat.new }

  describe '#gatito' do
    it 'debería decir hola' do
      gatito.hola
    end
  end
end