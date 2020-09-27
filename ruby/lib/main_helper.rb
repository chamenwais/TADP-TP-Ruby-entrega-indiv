require 'set'

module MethodInterceptors

  def invariant(&condicion)
    eval_condicion = proc { |instancia| raise RuntimeError unless instancia.instance_eval(&condicion) }
    before_and_after_each_call(eval_condicion, eval_condicion)
  end

  def llamar_before_procs(instancia)
    self.instance_variable_get(:@before_list).each { |bloque| instancia.instance_exec(instancia,&bloque) }
  end

  def llamar_after_procs(instancia)
    self.instance_variable_get(:@after_list).each { |bloque| instancia.instance_exec(instancia,&bloque) }
  end

  def diferent_of_initialize(method_name)
    method_name != :initialize
  end

  def method_added(method_name)
    @@recursing = true
    define_already_intercepted_methods
    define_intercepted_classes
    if diferent_of_method_added(method_name) &&
        not_intercepted(method_name) && has_requested_before_and_after
      @already_intercepted_methods << method_name
      unbound_method = self.instance_method(method_name)
      los_parametros = unbound_method.parameters
      if not_nil_and_not_empty(los_parametros) and last_parameter_is_a_block(los_parametros)
        define_method method_name do |*parametros|
          if (@@recursing)
            if self.class.diferent_of_initialize(method_name)
              begin
                self.class.llamar_before_procs(self)
              rescue RuntimeError => re
                @@recursing=true
                raise re
              end
              @@recursing = false
            end
            block=parametros.delete(parametros.last)
            retorno=unbound_method.bind(self).call(*parametros, &block)
            @@recursing = true
            self.class.llamar_after_procs(self)
            retorno
          end
        end
      elsif not_nil_and_not_empty(los_parametros) and !last_parameter_is_a_block(los_parametros)
        define_method method_name do |*parametros|
          if (@@recursing)
            if self.class.diferent_of_initialize(method_name)
              begin
              self.class.llamar_before_procs(self)
              rescue RuntimeError => re
                @@recursing=true
                raise re
              end
              @@recursing = false
            end
            retorno=unbound_method.bind(self).call(*parametros)
            @@recursing = true
            self.class.llamar_after_procs(self)
            retorno
          end
        end
      else
        define_method method_name do
          if (@@recursing)
            if self.class.diferent_of_initialize(method_name)
              begin
                self.class.llamar_before_procs(self)
              rescue RuntimeError => re
                @@recursing=true
                raise re
              end
              @@recursing = false
            end
            retorno=unbound_method.bind(self).call
            @@recursing = true
            self.class.llamar_after_procs(self)
            retorno
          end
        end
      end
    else
      super(method_name)
    end
  end

  def before_and_after_each_call(before, after)
    define_list_if_not_defined(:@before_list)
    define_list_if_not_defined(:@after_list)
    define_intercepted_classes
    self.instance_variable_get(:@before_list) << before
    self.instance_variable_get(:@after_list) << after
    @@intercepted_classes << self
  end

  private

  def diferent_of_method_added(method_name)
    method_name != :method_added
  end

  def get_last_parameter(parametros)
    parametros.last.first
  end

  def not_intercepted(method_name)
    !@already_intercepted_methods.include?(method_name)
  end

  def define_already_intercepted_methods
    is_not_defined = (defined? @already_intercepted_methods).nil?

    if is_not_defined
      @already_intercepted_methods = Set[]
    end
  end

  def not_nil_and_not_empty(parametros)
    !parametros.nil? and !parametros.empty?
  end

  def define_intercepted_classes
    is_not_defined = (defined? @@intercepted_classes).nil?

    if is_not_defined
      @@intercepted_classes = Set[]
    end
  end

  def last_parameter_is_a_block(parametros)
    "block".to_sym.eql? get_last_parameter(parametros)
  end

  def define_list_if_not_defined(sym_list)
    is_not_defined = self.instance_variable_get(sym_list).nil?

    if is_not_defined
      self.instance_variable_set(sym_list,[])
    end
  end

  def has_requested_before_and_after
    @@intercepted_classes.include?(self)
  end
end

class Class
  include MethodInterceptors
end