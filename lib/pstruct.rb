require 'ostruct'
require 'yaml'

# Simple subclass of OpenStruct adding automatic writing of
# the struct content to disk as a Hash.  Stores the underlying 
# Hash rep on modification or creation of attributes, but not
# on initialization.
#
#   > ps = PStruct.new('/tmp/ps.yml', :foo => :bar)
#   => #<PStruct foo=:bar>
#   > ps.foo
#   => :bar
#   > puts File.read('/tmp/ps.yml')
#   => Errno::ENOENT: No such file or directory - /tmp/ps.yml
#   > ps.commit
#   => nil
#   > puts File.read('/tmp/ps.yml')
#   ---
#   :foo: :bar
#   => nil
#   > ps.bar = :baz
#   => :baz
#   puts File.read('/tmp/ps.yml')
#   ---
#   :bar: :baz
#   :foo: :bar
#   => nil
#
#   > ps = PStruct.load('/tmp/ps.yml')
#   => #<PStruct bar=:baz, foo=:bar>
#   > ps.bar
#   => :baz
#
class PStruct < OpenStruct
  attr_accessor :file

  # Create a new PStruct with persistance +file+. The optional
  # +hash+ will be passed on to the OpenStruct initializer.
  def initialize(file, hash = nil)
    @file = file
    super(hash)
  end

  # Load from the persistence file.
  def load
    marshal_load(YAML.load_file(file) || {})
  end

  # Commit the rep to the persistence file.
  def commit
    File.open(file, 'w') {|f| YAML.dump(marshal_dump, f)}
    nil
  end

  # This is overridden wholesale to modify the setter method
  # definition to commit when values are set.  Brittle!  Tested
  # against 1.8.7-p174 and 1.9.2-p180.
  def new_ostruct_member(name)
    name = name.to_sym
    unless self.respond_to?(name)
      class << self; self; end.class_eval do
        define_method(name) { @table[name] }
        define_method("#{name}=") do |x|
          if respond_to?(:modifiable)
            modifiable[name] = x     ## 1.9.x
          else
            @table[name] = x         ## 1.8.x
          end
          commit
          x
        end
      end
    end
    name
  end

  # Override to automatically commit when a new attribute is
  # created through initial assignment.
  def method_missing(mid, *args)
    super
    commit if mid.id2name.chomp!('=')
  end

  # Override to automatically commit when a field is deleted.
  def delete_field(name)
    super
    commit
  end

  class << self

    # Load and instantiate from +file+.
    def load(file)
      obj = new(file)
      obj.load
      obj
    end

  end

end
