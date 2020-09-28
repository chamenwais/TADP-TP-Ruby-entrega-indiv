require 'set'

module MethodInterceptors

  # Lógica de los before and after (punto 1)

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
  def llamar_before_procs
    @before_list.each { |bloque| bloque.call }
  end
  # Invocacion de los procs de tipo AFTER
  def llamar_after_procs
    @after_list.each { |bloque| bloque.call }
  end

  ## Inicializacion de listas de before and after
  def before_and_after_each_call(before, after)
    initialize_before_list
    initialize_after_list
    initialize_before_and_after_classes
    @before_list << before
    @after_list << after
    @@classes_with_before_and_after << self
  end

  # Devuelve si la propia clase tiene before and after
  def has_requested_before_and_after
    initialize_before_and_after_classes
    @@classes_with_before_and_after.include?(self)
  end

  # Lógica para invariantes (punto 2)
  # Inicializa lista de clases que tienen algún invariante
  def initialize_invariants_classes
    @@classes_with_invariants = Set[] if (defined? @@classes_with_invariants).nil?
  end

  # Devuelve si la propia clase tiene invariants
  def has_requested_invariant
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
  define_method :check_invariants do |instance|
    if @invariantes.any? { |condicion|  !(instance.instance_eval &condicion) }
      raise "Hay un invariante que dejó de cumplirse!"
    end
  end

  # Devuelve si un metodo es getter de una instancia
  def is_a_getter?(instancia,method_name)
    instancia.instance_variables.any? do |variable|
      variable.to_s[1..-1].eql? method_name.to_s
    end
  end

  # Inicializa lista de métodos interceptados
  def initialize_intercepted_methods
    @already_intercepted_methods = Set[] if (defined? @already_intercepted_methods).nil?
  end

  # Redefinicion de métodos (común a todos los puntos)
  def method_added(method_name)
    @@recursing = true
    # Se inicializa lista de metodos intereceptados para una clase particular!
    initialize_intercepted_methods

    if method_name != :method_added && not_intercepted(method_name)
      @already_intercepted_methods << method_name
        unbound_method = self.instance_method(method_name)
        los_parametros = unbound_method.parameters
        if has_any_parameter?(los_parametros) and last_parameter_is_a_block(los_parametros)
          if (@@recursing)
            define_method method_name do |*parametros|
              if self.class.has_requested_before_and_after
                self.class.llamar_before_procs
              end

              @@recursing = false
              block=parametros.delete(parametros.last)
              retorno = unbound_method.bind(self).call(*parametros, &block)
              if self.class.has_requested_before_and_after
                self.class.llamar_after_procs
              end

              @@recursing = true

              if self.class.has_requested_invariant && !self.class.is_a_getter?(self,method_name)
                self.class.check_invariants(self)
              end
              retorno
            end
        end
        elsif has_any_parameter?(los_parametros) and !last_parameter_is_a_block(los_parametros)
          define_method method_name do |*parametros|
            if (@@recursing)
              if self.class.has_requested_before_and_after
                self.class.llamar_before_procs
              end
              @@recursing = false
              retorno =unbound_method.bind(self).call(*parametros)
              if self.class.has_requested_before_and_after
                self.class.llamar_after_procs
              end
              @@recursing = true
              if self.class.has_requested_invariant && !self.class.is_a_getter?(self,method_name)
                self.class.check_invariants(self)
              end
              retorno
            end
          end
        else
          # No tiene parámetros
          define_method method_name do
            if (@@recursing)
              if self.class.has_requested_before_and_after
                self.class.llamar_before_procs
              end
              @@recursing = false
              retorno = unbound_method.bind(self).call
              if self.class.has_requested_before_and_after
                self.class.llamar_after_procs
              end
              @@recursing = true
              if self.class.has_requested_invariant && !self.class.is_a_getter?(self,method_name)
                self.class.check_invariants(self)
              end
              retorno
            end
          end
        end

    end
  end

  # Devuelve si un método ya fue interceptado y redefinido
  def not_intercepted(method_name)
    !@already_intercepted_methods.include?(method_name)
  end

  # Devuelve si una lista de parámetros tiene algún valor
  def has_any_parameter?(parametros)
    !parametros.nil? and !parametros.empty?
  end

  # Lógica de obtención de parámetros

  # Devuelve si el último parámetro de una lista es un bloque
  def last_parameter_is_a_block(parametros)
    "block".to_sym.eql? get_last_parameter(parametros)
  end

  # Devuelve el último parametro
  def get_last_parameter(parametros)
    parametros.last.first
  end
end

class Class
  include MethodInterceptors
end
