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


# Override some default YAML Behavior and create OpenStructs instead of Hashes when called
# http://rubyquiz.com/quiz81.html
class << YAML::DefaultResolver
    alias_method :_node_import, :node_import
    def node_import(node)
        o = _node_import(node)
        o.is_a?(Hash) ? OpenStruct.new(o) : o
    end
end


# Create new features for the OStruct class
# http://snippets.dzone.com/tag/hash
# This class provides a few new capabilities in addition to what is provided by
# the OpenStruct class.  The method _to_hash will return a hash representation of
# the struct, including nested structs.  The method _table will return a hash
# representation, but will not resolve any nested structs.  The method
# _manual_set takes a hash and adds it to the struct. This is similar to
# OpenStruct's ability to take a hash as an initial argument to create a struct,
# this method allows the struct to be modifed post instantiation.  The method
# names start with an _ (underscore) to avoid any conflicts between these methods
# and struct assignments.  Implementation note: I created a new class rather than
# extending the existing OpenStruct class due to my personal preference of not
# changing the behavior for standard library classes. However, one could just as
# easily extend the OpenStruct class with these behaviors as well.
class OpenStruct
  def _to_hash
    h = @table
    #handles nested structures
    h.each do |k,v|
      if v.class == OpenStruct
        h[k] = v._to_hash
      end
    end
    return h
  end
  
  def _table
    @table   #table is the hash structure used in OpenStruct
  end
  
  def _manual_set(hash)
    if hash && (hash.class == Hash)
      for k,v in hash
        @table[k.to_sym] = v
        new_ostruct_member(k)
      end
    end
  end
end

# == Ninjapatching for Ruby
class Array
    def delete_unless &block
        delete_if{ |element| not block.call( element ) }
    end

    # super nifty way of chunking an Array to n parts
    # found http://drnicwilliams.com/2007/03/22/meta-magic-in-ruby-presentation/
    # direct original source at http://redhanded.hobix.com/bits/matchingIntoMultipleAssignment.html
    def %(len)
        inject([]) do |array, x|
            array << [] if [*array.last].nitems % len == 0
            array.last << x
            array
        end
    end

    # now e.g. this is possible
    #test = false
    #if(test)
    #    array = Array.new
    #    0.upto(10) {|n| array << "foo"+n.to_s }
    #    p array%3
    #end

    # % ./Extensions.rb 
    # ["foo0", "foo1", "foo2", "foo3", "foo4", "foo5", "foo6", "foo7", "foo8", "foo9", "foo10"]
    # % ./Extensions.rb
    #[ ["foo0", "foo1", "foo2"], ["foo3", "foo4", "foo5"], ["foo6", "foo7", "foo8"], ["foo9", "foo10"]]


    def sum
      inject( nil ) { |sum,x| sum ? sum+x : x }
    end

    def mean
      sum / size
    end
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




