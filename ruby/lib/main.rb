# frozen_string_literal: true

module MethodInterceptors
  def self.included(klass)
    klass.class_eval do
      def self.method_added(method_name)
        puts method_name
      end
    end
  end

  def before_and_after_each_call(before, after)
    puts 'Hello'
  end


end

class Cat
  include MethodInterceptors

  def hello_world(name)
    puts "Hello #{name}"
  end
end

my_cat = Cat.new
my_cat.hello_world('Paul')
my_cat.hello_world('Paul')
