class Module
  def before_and_after_each_call(bloque1, bloque2)
=begin    @before = []
    @after = []
    @before << bloque1
    @after << bloque2
    ejecutar_before
=end
    #    bloque1.call
    #bloque2.call
  end

  private
  def ejecutar_bloques
    @before.each { |bloque| bloque.call }
    # ejecutar el metodo original
    @after.each { |bloque| bloque.call }
  end
end

class Class
  #attr_accessor :before, :after
  define_method :method_added do |method_name|
    if(method_name != :method_added)
      define_method :method_name do
        self.llamarBeforeProcs
        send(:method_name)
        self.llamarAfterProcs
      end
      puts "Se agrego el metodo #{method_name}"
    end
  end
end