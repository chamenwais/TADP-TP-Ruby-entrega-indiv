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

  def before_and_after_each_call(before, after)
    isNotDefined = (defined? @@before_list).nil?

    if isNotDefined
      @@before_list = []
    end

    isNotDefined = (defined? @@after_list).nil?

    if isNotDefined
      @@after_list = []
    end

    @@before_list << before
    @@after_list << after
  end
end

class Class
  include MethodInterceptors

end


class Cat

  before_and_after_each_call(proc { puts 'before' }, proc { puts 'after' })
  def hello_world(name)
    puts "Hello #{name}"
  end
end

my_cat = Cat.new
my_cat.hello_world('Paul')
# my_cat.hello_world('Paul')




