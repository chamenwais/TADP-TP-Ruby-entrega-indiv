describe Prueba do
  let(:prueba) { Prueba.new(1) }

  describe '#materia' do
    it 'debería pasar este test' do
      expect(prueba.materia).to be :tadp
    end
  end

  describe '#anio' do
    it 'deberia ser 2020' do
      expect(prueba.anio).to eq(2020)
    end
  end

  describe '#notaPromo prueba metodo con parametros' do
    it 'para antes del 2016 era 4' do
      expect(prueba.notaPromo(2013,2020)).to eq(4)
    end
    it 'despues del 2016 es 6' do
      expect(prueba.notaPromo(2017,2020)).to eq(6)
    end
  end

  describe '#agregadoDespues' do
    it 'deberia ser 2020' do
      expect(prueba.agregadoDespues).to eq("anda!")
    end
  end

  describe '#agregadoDespues2' do
    it 'deberia andar' do
      expect(prueba.agregadoBasntanteDespues).to eq("noVaAAndar")
    end
  end

end