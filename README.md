Persistent OpenStruct with PStruct
==================================

PStruct is a subclass of OpenStruct which adds automatic, file-backed persistance.

Example
=======

    > ps = PStruct.new('/tmp/ps.yml', :foo => :bar)
    => #<PStruct foo=:bar>
    > ps.foo
    => :bar
    > puts File.read('/tmp/ps.yml')
    => Errno::ENOENT: No such file or directory - /tmp/ps.yml
    > ps.commit
    => nil
    > puts File.read('/tmp/ps.yml')
    ---
    :foo: :bar
    => nil
    > ps.bar = :baz
    => :baz
    puts File.read('/tmp/ps.yml')
    ---
    :bar: :baz
    :foo: :bar
    => nil
 
    > ps = PStruct.load('/tmp/ps.yml')
    => #<PStruct bar=:baz, foo=:bar>
    > ps.bar
    => :baz
  
