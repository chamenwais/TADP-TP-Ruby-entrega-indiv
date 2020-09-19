# frozen_string_literal: true
require 'set'

module MethodInterceptors
  def self.included(klass)
    klass.class_eval do
      def self.method_added(method_name)
        # method = self.instance_method(method_name)
        isNotDefined = (defined? @@already_intercepted_methods).nil?

        if isNotDefined
          @@already_intercepted_methods = Set[]
        end
        puts @@already_intercepted_methods

        if method_name != :method_added && @@already_intercepted_methods.include?(method_name)
          define_method method_name do
            # self.llamarBeforeProcs
            send(method_name)
            # method
            # self.llamarAfterProcs
          end
          puts "Se agrego el metodo #{method_name}"
          @@already_intercepted_methods << method_name
        end
      end
    end
  end
end

class Cat
  include MethodInterceptors

  # before_and_after_each_call(proc { puts 'before' }, proc { puts 'after' })

  def hello_world(name)
    puts "Hello #{name}"
  end
end

my_cat = Cat.new
my_cat.hello_world('Paul')
# my_cat.hello_world('Paul')


# def call_procs_after
#   self.class.singleton_class.instance_variable_get(:@after_list).each(&:call)
# end
#
# def call_procs_before
#   self.class.singleton_class.instance_variable_get(:@before_list).each(&:call)
# end

# def before_and_after_each_call(before, after)
#   singleton_class.instance_variable_set(:@before_list, []) if singleton_class.instance_variable_get(:@before_list).nil? # TODO: Can we access directly to variables?
#   singleton_class.instance_variable_set(:@after_list, []) if singleton_class.instance_variable_get(:@after_list).nil?
#
#   singleton_class.instance_variable_get(:@before_list) << before
#   singleton_class.instance_variable_get(:@after_list) << after
# end