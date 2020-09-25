require 'set'

module MethodInterceptors
  def llamar_before_procs
    if @before_list != nil
      @before_list.each { |bloque| bloque.call }
    end
  end

  def llamar_after_procs
    if @after_list != nil
      @after_list.each { |bloque| bloque.call }
    end
  end

  def method_added(method_name)
    @@recursing = true
    define_aleady_intercepted_methods
    if method_name != :method_added && not_intercepted(method_name)
      @already_intercepted_methods << method_name
      unbound_method = self.instance_method(method_name)
      los_parametros = unbound_method.parameters[0]
      if not_nil_and_not_empty(los_parametros)
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

    @before_list << before
    @after_list << after
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
end

class Class
  include MethodInterceptors
end
