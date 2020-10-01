require 'set'

module MethodInterceptors


  # Inicializa lista de clases que tienen before and after
  def initialize_before_and_after_classes
    @@classes_with_before_and_after = Set[] if (defined? @@classes_with_before_and_after).nil?
  end

  # Inicializa lista de procs before
  def initialize_before_list
    @before_list = [] if (defined? @before_list).nil?
  end

  # Inicializa lista de procs after
  def initialize_after_list
    @after_list = [] if (defined? @after_list).nil?
  end

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
    initialize_before_list
    initialize_after_list
    initialize_before_and_after_classes
    @before_list << before
    @after_list << after
    @@classes_with_before_and_after << self
  end

  # Devuelve si la propia clase tiene before and after
  def has_before_and_after?
    initialize_before_and_after_classes
    @@classes_with_before_and_after.include?(self)
  end

  # Inicializa lista de clases que tienen algún invariante
  def initialize_invariants_classes
    @@classes_with_invariants = Set[] if (defined? @@classes_with_invariants).nil?
  end

  # Devuelve si la propia clase tiene invariants
  def has_invariant?
    initialize_invariants_classes
    @@classes_with_invariants.include?(self)
  end

  # Almacena la condición a cumplir y agrega la clase a una lista de clases que tienen invariantes
  def invariant(&condicion)
    @invariantes = [] if @invariantes.nil?
    @invariantes << condicion
    initialize_invariants_classes
    @@classes_with_invariants << self
  end

  # Chequeo de los invariantes existentes
  def check_invariants(instance)
    if @invariantes.any? do |condicion|
      !(instance.instance_eval &condicion)
    end
      raise "Hay un invariante que dejó de cumplirse!"
    end
  end

  # Devuelve si un metodo es getter de una instancia
  def is_a_getter?(instancia,method_name)
    instancia.class.instance_methods(false).include? (method_name.to_s + "=").to_sym
    #    instancia.class.instance_methods.any? do |metodo|
    # metodo.to_s[1..-1].eql? method_name.to_s
  end

  # Inicializa lista de métodos interceptados
  def initialize_intercepted_methods
    @already_intercepted_methods = Set[] if (defined? @already_intercepted_methods).nil?
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

  # Lógica para PRE
  def pre(&precondicion)
    unless @precondicion.nil?
      raise "Ya se había definido una precondición!"
    end
    @precondicion = precondicion
  end

  # Lógica para POST
  def post(&postcondicion)
    unless @postcondicion.nil?
      raise "Ya se había definido una postcondición!"
    end
    @postcondicion = postcondicion
  end

  # Arma un hash con los parámetros enviados en un método (para aplicar en los pre y post)
  def get_params_dictionary(valores, parametros)
    params = {}
    parametros.each_with_index do |parametro, index|
      params[parametro[1].to_s] = valores[index]
    end
    params
  end

  # Redefine el method_missing de la instancia particular! (Singleton Class)
  def define_method_missing_for_instance(instancia)
    if @method_missing_defined.nil?
      class << instancia
        def method_missing(method, *args)
          parametros = self.singleton_class.instance_variable_get(:@method_params)
          parametros[method.to_s]
        end
      end
      @method_missing_defined = nil
    end
  end

  # Redefinicion de métodos (común a todos los puntos)
  def method_added(method_name)
    # Se inicializa lista de metodos intereceptados para una clase particular!
    initialize_intercepted_methods
    if method_name != :method_added && not_intercepted(method_name)
      # Se guarda el metodo como ya interceptado
      @already_intercepted_methods << method_name
      unbound_method = self.instance_method(method_name)

      # Se obtienen la precondicion y postcondicion de turno
      precondicion = @precondicion
      postcondicion = @postcondicion

      # Redefinicion del método
      define_method method_name do |*parametros|
        # Se redefine el method missing de esa instancia (para pre y post)
        self.class.define_method_missing_for_instance(self)
        key_values = self.class.get_params_dictionary(parametros, unbound_method.parameters)
        self.singleton_class.instance_variable_set(:@method_params, key_values)

        # Validación de precondición si existe
        raise "No se cumple la precondición para el método #{method_name.to_s}" if !precondicion.nil? && !self.instance_exec(key_values, &precondicion)

        # Ejecución de procs de before si existen
        self.class.call_before_procs if self.class.has_before_and_after? && !self.class.is_a_getter?(self,method_name)

        # Ejecución de código original, previo a redefinición
        if self.class.has_any_parameter?(unbound_method.parameters) && self.class.last_parameter_is_a_block(unbound_method.parameters)
          block=parametros.delete(parametros.last)
          retorno = unbound_method.bind(self).call(*parametros, &block)
        else
          retorno = unbound_method.bind(self).call(*parametros)
        end

        # Ejecución de procs de after si existen
        self.class.call_after_procs if self.class.has_before_and_after? && !self.class.is_a_getter?(self,method_name)

        # Validación de invariantes si es que existen
        self.class.check_invariants(self) if self.class.has_invariant? && !self.class.is_a_getter?(self,method_name)

        # Validación de postcondición si existe
        raise "No se cumple la postcondicion para el método #{method_name.to_s}" if !postcondicion.nil? && !(self.instance_exec retorno, key_values, &postcondicion)

        retorno
      end
      @precondicion = nil
      @postcondicion = nil
    end
  end
end

class Class
  include MethodInterceptors
end

