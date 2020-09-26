require 'set'

module MethodInterceptors

  def invariant(&condicion)
    if @invariantes.nil?
      @invariantes = []
    end
    @invariantes << condicion
    define_classes_with_invariants
    @@classes_with_invariants << self
  end

  define_method :verificar_invariantes do |instancia|
    if @invariantes.any? {|condicion| !(instancia.instance_eval(&condicion)) }
      raise RuntimeError
    end
  end

  def initialize(*parametros)
    if @@classes_with_invariants.include?self
      self.class.verificar_invariantes(self)
    end
    puts "initialize"
    super(*parametros)
  end

  def llamar_before_procs
    @before_list.each { |bloque| bloque.call }
  end

  def llamar_after_procs
    @after_list.each { |bloque| bloque.call }
  end

  def method_added(method_name)
    @@recursing = true
    define_aleady_intercepted_methods
    if method_name != :method_added && not_intercepted(method_name) && has_requested_before_and_after
      @already_intercepted_methods << method_name
      unbound_method = self.instance_method(method_name)
      los_parametros = unbound_method.parameters
      if not_nil_and_not_empty(los_parametros) and last_parameter_is_a_block(los_parametros)
        define_method method_name do |*parametros|
          if (@@recursing)
            self.class.llamar_before_procs
            @@recursing = false
            block=parametros.delete(parametros.last)
            unbound_method.bind(self).call(*parametros, &block)
            self.class.llamar_after_procs
            @@recursing = true
          end
        end
      elsif not_nil_and_not_empty(los_parametros) and !last_parameter_is_a_block(los_parametros)
        define_method method_name do |*parametros|
          if (@@recursing)
            self.class.llamar_before_procs
            @@recursing = false
            unbound_method.bind(self).call(*parametros)
            self.class.llamar_after_procs
            @@recursing = true
          end
        end
      else
        define_method method_name do
          if (@@recursing)
            self.class.llamar_before_procs
            @@recursing = false
            unbound_method.bind(self).call
            self.class.llamar_after_procs
            @@recursing = true
          end
        end
      end
    end
  end

  def before_and_after_each_call(before, after)
    define_before_list_if_not_defined
    define_after_list_if_not_defined
    define_classes_with_before_and_after
    @before_list << before
    @after_list << after
    @@classes_with_before_and_after << self
  end

  private

  def not_intercepted(method_name)
    !@already_intercepted_methods.include?(method_name)
  end

  def define_aleady_intercepted_methods
    isNotDefined = (defined? @already_intercepted_methods).nil?

    if isNotDefined
      @already_intercepted_methods = Set[]
    end
  end

  def define_classes_with_before_and_after
    is_not_defined = (defined? @@classes_with_before_and_after).nil?

    if is_not_defined
      @@classes_with_before_and_after = Set[]
    end
  end

  def define_classes_with_invariants
    is_not_defined = (defined? @@classes_with_invariants).nil?

    if is_not_defined
      @@classes_with_invariants = Set[]
    end
  end

  def not_nil_and_not_empty(parametros)
    !parametros.nil? and !parametros.empty?
  end

  def define_after_list_if_not_defined
    isNotDefined = (defined? @after_list).nil?

    if isNotDefined
      @after_list = []
    end
  end

  def define_before_list_if_not_defined
    isNotDefined = (defined? @before_list).nil?

    if isNotDefined
      @before_list = []
    end
  end

  def has_requested_before_and_after
    @@classes_with_before_and_after.include?(self)
  end

  def last_parameter_is_a_block(parametros)
    "block".to_sym.eql? get_last_parameter(parametros)
  end

  def get_last_parameter(parametros)
    parametros.last.first
  end
end

class Class
  include MethodInterceptors
end
