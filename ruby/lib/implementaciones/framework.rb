require 'set'

module MethodInterceptors

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

  # Devuelve si un metodo es getter de una instancia
  def is_a_getter?(instancia,method_name)
    instancia.class.instance_methods(false).include? (method_name.to_s + "=").to_sym
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

  def definir_getters_parametros(*args, args_symbols, instancia)
    args.each_with_index do |arg, index|
      nombre_param = args_symbols[index].last
      instancia.define_singleton_method nombre_param do
        arg
      end
    end
  end

  def copiar(instance, method_parameters, parametros)
    copy = instance.class.send(:new,*instance.instance_variable_get(:@params_initialize))

    # Seteo de estado
    instance.instance_variables.each do |sym_atributo|
      valor_atributo=instance.instance_variable_get(sym_atributo)
      copy.instance_variable_set(sym_atributo,valor_atributo)
    end
    # Agregado de getters con los parámetros del método
    definir_getters_parametros(*parametros, method_parameters, copy)
    copy
  end

  # Redefinicion de métodos (común a todos los puntos)
  def method_added(method_name)
    # Se inicializa lista de metodos intereceptados para una clase particular!
    initialize_intercepted_methods

    if method_name != :method_added && not_intercepted(method_name) && (!self.instance_variable_get(:@has_before_and_after).nil? or
        !self.instance_variable_get(:@has_invariant).nil? or
        !self.instance_variable_get(:@has_pre_or_postcondition).nil?)
      # Se guarda el metodo como ya interceptado
      @already_intercepted_methods << method_name
      @@recursing_initialize ||=false
      unbound_method = self.instance_method(method_name)

      # Se obtienen la precondicion y postcondicion de turno
      precondicion = @precondicion
      postcondicion = @postcondicion

      # Redefinicion del método
      define_method method_name do |*parametros|

        if method_name == :initialize
          self.instance_variable_set(:@params_initialize , parametros)
          @@recursing_initialize ||=true
        else
          copia = self.class.copiar(self,unbound_method.parameters,parametros)
        end

        # Validación de precondición si existe
        raise "No se cumple la precondición para el método #{method_name.to_s}" if !precondicion.nil? && !copia.instance_eval(&precondicion)

        # Ejecución de procs de before si existen
        self.class.call_before_procs if !self.class.instance_variable_get(:@has_before_and_after).nil? && !self.class.is_a_getter?(self,method_name)

        # Ejecución de código original, previo a redefinición
        if self.class.has_any_parameter?(unbound_method.parameters) && self.class.last_parameter_is_a_block(unbound_method.parameters)
          block=parametros.delete(parametros.last)
          retorno = unbound_method.bind(self).call(*parametros, &block)
        else
          retorno = unbound_method.bind(self).call(*parametros)
        end

        # Ejecución de procs de after si existen
        self.class.call_after_procs if !self.class.instance_variable_get(:@has_before_and_after).nil? && !self.class.is_a_getter?(self,method_name)

        # Validación de invariantes si es que existen
        self.class.check_invariants(self) if !self.class.instance_variable_get(:@has_invariant).nil? && !self.class.is_a_getter?(self,method_name)

        if (!@@recursing_initialize)
          copia = self.class.copiar(self, unbound_method.parameters,parametros)
          # Validación de postcondición si existe
          raise "No se cumple la postcondicion para el método #{method_name.to_s}" if !postcondicion.nil? && !(copia.instance_exec retorno, &postcondicion)
        else
          @@recursing_initialize ||=false
        end

        retorno
      end
      @precondicion = nil
      @postcondicion = nil
    else
      super method_name
    end
  end
end

class Class
  include MethodInterceptors
end

