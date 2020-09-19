# frozen_string_literal: true
require 'set'

module MethodInterceptors
  def llamar_before_procs
    puts "llamar_before_procs"
    @@before_list.each {|bloque| bloque.call}
  end

  def llamar_after_procs
    puts "llamar_after_procs"
    @@after_list.each {|bloque| bloque.call}
  end

  def method_added(method_name)
    @@recursing= true
    isNotDefined = (defined? @@already_intercepted_methods).nil?

    if isNotDefined
      @@already_intercepted_methods = Set[]
    end

    if method_name != :method_added && !@@already_intercepted_methods.include?(method_name)
      puts "Se agrego el metodo #{method_name}"
      @@already_intercepted_methods << method_name
      # unbound_method = self.method(method_name)
      # puts unbound_method
      define_method method_name do
        if(@@recursing)
          self.class.llamar_before_procs


          @@recursing=false
          send(method_name)
          self.class.llamar_after_procs
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
  before_and_after_each_call(proc { puts 'before2' }, proc { puts 'after2' })
  def hello_world
    puts "Hello"
  end
  # def hello_world_con_nombre(name)
  #   puts "Hello #{name}"
  # end
end

my_cat = Cat.new
my_cat.hello_world
# my_cat.hello_world('Paul')




