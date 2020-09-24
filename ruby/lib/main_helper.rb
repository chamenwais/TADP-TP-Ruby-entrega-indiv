require 'set'

module MethodInterceptors
  def llamar_before_procs
    self.instance_variable_get(:@before_list).each { |bloque| bloque.call }
  end

  def llamar_after_procs
    self.instance_variable_get(:@after_list).each { |bloque| bloque.call }
  end

  def method_added(method_name)
    @@recursing = true
    define_already_intercepted_methods
    define_intercepted_classes
    if method_name != :method_added && not_intercepted(method_name) && has_requested_before_and_after
      @@already_intercepted_methods << method_name
      unbound_method = self.instance_method(method_name)
      los_parametros = unbound_method.parameters
      if not_nil_and_not_empty(los_parametros) and last_parameter_is_a_block(los_parametros)
        define_method method_name do |*parametros|
          if (@@recursing)
            self.class.llamar_before_procs
            @@recursing = false
            block=parametros.delete_at(parametros.size-1)
            retorno=unbound_method.bind(self).call(*parametros, &block)
            self.class.llamar_after_procs
            @@recursing = true
            retorno
          end
        end
      elsif not_nil_and_not_empty(los_parametros) and !last_parameter_is_a_block(los_parametros)
        define_method method_name do |*parametros|
          if (@@recursing)
            self.class.llamar_before_procs
            @@recursing = false
            retorno=unbound_method.bind(self).call(*parametros)
            self.class.llamar_after_procs
            @@recursing = true
            retorno
          end
        end
      else
        define_method method_name do
          if (@@recursing)
            self.class.llamar_before_procs
            @@recursing = false
            retorno=unbound_method.bind(self).call
            self.class.llamar_after_procs
            @@recursing = true
            retorno
          end
        end
      end
    else
      super
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

  def get_last_parameter(parametros)
    parametros[parametros.size - 1][0]
  end

  def not_intercepted(method_name)
    !@@already_intercepted_methods.include?(method_name)
  end

  def define_already_intercepted_methods
    is_not_defined = (defined? @@already_intercepted_methods).nil?

    if is_not_defined
      @@already_intercepted_methods = Set[]
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