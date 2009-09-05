#!/usr/bin/ruby
#

#class Object
#end
#
class Object
  def deep_clone_simple
    Marshal::load(Marshal.dump(self))
  end

  def deep_clone
    return @deep_cloning_obj if @deep_cloning
    @deep_cloning_obj = clone
    @deep_cloning_obj.instance_variables.each do |var|
      val = @deep_cloning_obj.instance_variable_get(var)
      begin
  @deep_cloning = true
  val = val.deep_clone
      rescue TypeError
  next
      ensure
  @deep_cloning = false
      end
      @deep_cloning_obj.instance_variable_set(var, val)
    end
    deep_cloning_obj = @deep_cloning_obj
    @deep_cloning_obj = nil
    deep_cloning_obj
  end


  def dclone
    case self
      when Fixnum,Bignum,Float,NilClass,FalseClass,
           TrueClass,Continuation
        klone = self
      when Hash
        klone = self.clone
        self.each{|k,v| klone[k] = v.dclone}
      when Array
        klone = self.clone
        klone.clear
        self.each{|v| klone << v.dclone}
      else
        klone = self.clone
    end
    klone.instance_variables.each {|v|
      klone.instance_variable_set(v,
        klone.instance_variable_get(v).dclone)
    }
    klone
  end


#  # http://doc.okkez.net/191/view/method/Object/i/initialize_copy
#  def check(obj)
#    # puts "instance variables: #{obj.inspect}"
#    puts "tainted?: #{obj.tainted?}"
#    print "singleton methods: "
#    begin
#      p obj.bar
#    rescue NameError
#      p $!
#    end
#  end
#
end
