require 'set'

module BeforeAndAfterMixin
  # Invocacion de los procs de tipo BEFORE
  def call_before_procs
    @before_list.each { |bloque| bloque.call }
  end

  # Invocacion de los procs de tipo AFTER
  def call_after_procs
    @after_list.each { |bloque| bloque.call }
  end

  # Inicializacion de listas de before and after
  def before_and_after_each_call(before, after)
    @before_list ||= []
    @after_list ||= []
    @before_list << before
    @after_list << after
    @has_before_and_after ||= true
  end
end

module InvariantsMixin
  # Almacena la condición a cumplir y agrega la clase a una lista de clases que tienen invariantes
  def invariant(&condicion)
    @invariantes ||= []
    @invariantes << condicion
    @has_invariant ||= true
  end

  # Chequeo de los invariantes existentes
  def check_invariants(instance)
    if @invariantes.any? { |condicion| !(instance.instance_eval &condicion) }
      raise "Hay un invariante que dejó de cumplirse!"
    end
  end
end

module MethodInterceptorMixin

  # Devuelve si un metodo es setter de una instancia
  def is_a_setter?(method_name)
    method_name.to_s[method_name.to_s.length-1].eql? "="
  end

  # Inicializa lista de métodos interceptados
  def initialize_intercepted_methods
    @already_intercepted_methods ||= Set[]
  end

  # Devuelve si un método ya fue interceptado y redefinido
  def not_intercepted(method_name)
    !@already_intercepted_methods.include?(method_name)
  end

  # Devuelve si una lista de parámetros tiene algún valor
  def has_any_parameter?(parametros)
    !parametros.nil? and !parametros.empty?
  end

  # Devuelve el último parametro
  def get_last_parameter(parametros)
    parametros.last.first
  end

  # Devuelve si el último parámetro de una lista es un bloque
  def last_parameter_is_a_block(parametros)
    "block".to_sym.eql? get_last_parameter(parametros)
  end
  # Redefinicion de métodos (común a todos los puntos)
  def method_added(method_name)
    # Se inicializa lista de metodos intereceptados para una clase particular!
    initialize_intercepted_methods

    if method_name != :method_added && not_intercepted(method_name) && (!self.instance_variable_get(:@has_before_and_after).nil? or
        !self.instance_variable_get(:@has_invariant).nil? or
        !self.instance_variable_get(:@has_pre_or_postcondition).nil? or is_a_setter?(method_name))
      # Se guarda el metodo como ya interceptado
      @already_intercepted_methods << method_name
      unbound_method = self.instance_method(method_name)

      # Se obtienen la precondicion y postcondicion de turno
      precondicion = @precondicion
      postcondicion = @postcondicion

      # Redefinicion del método
      define_method method_name do |*parametros|

        copia = self.class.copiar(self, unbound_method.parameters, parametros)

        # Validación de precondición si existe
        raise "No se cumple la precondición para el método #{method_name.to_s}" if !precondicion.nil? && !copia.instance_eval(&precondicion)

        # Ejecución de procs de before si existen
        self.class.call_before_procs if !self.class.instance_variable_get(:@has_before_and_after).nil?

        # Ejecución de código original, previo a redefinición
        if self.class.has_any_parameter?(unbound_method.parameters) && self.class.last_parameter_is_a_block(unbound_method.parameters)
          block=parametros.delete(parametros.last)
          retorno = unbound_method.bind(self).call(*parametros, &block)
        else
          retorno = unbound_method.bind(self).call(*parametros)
        end

        # Ejecución de procs de after si existen
        self.class.call_after_procs if !self.class.instance_variable_get(:@has_before_and_after).nil?

        # Validación de invariantes si es que existen
        self.class.check_invariants(self) if !self.class.instance_variable_get(:@has_invariant).nil?

        copia = self.class.copiar(self, unbound_method.parameters, parametros)
        # Validación de postcondición si existe
        raise "No se cumple la postcondicion para el método #{method_name.to_s}" if !postcondicion.nil? && !(copia.instance_exec retorno, &postcondicion)

        retorno
      end
      @precondicion = nil
      @postcondicion = nil
    else
      super method_name
    end
  end
end

module PreAndPostConditionsMixin
  # Lógica para PRE
  def pre(&precondicion)
    unless @precondicion.nil?
      raise "Ya se había definido una precondición!"
    end
    @precondicion = precondicion
    @has_pre_or_postcondition ||= true
  end

  # Lógica para POST
  def post(&postcondicion)
    unless @postcondicion.nil?
      raise "Ya se había definido una postcondición!"
    end
    @postcondicion = postcondicion
    @has_pre_or_postcondition ||= true
  end

end

module CloneFactoryMixin
  # Define getters para parámetros de métodos en la singleton class de la instancia que lo ejecuta
  def definir_getters_parametros(*args, args_symbols, instancia)
    args.each_with_index do |arg, index|
      nombre_param = args_symbols[index].last
      instancia.define_singleton_method nombre_param do
        arg
      end
    end
  end

  # Crea una copia de un objeto y le agrega getters que se corresponden con parámetros de métodos
  def copiar(instance, method_parameters, parametros)
    # Creación de la instancia
    copy = instance.clone
    # Agregado de getters con los parámetros del método
    definir_getters_parametros(*parametros, method_parameters, copy)
    copy
  end

end

class Class
  include BeforeAndAfterMixin
  include InvariantsMixin
  include PreAndPostConditionsMixin
  include CloneFactoryMixin
  include MethodInterceptorMixin
end

