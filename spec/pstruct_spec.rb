require File.join(File.dirname(__FILE__), '../lib/pstruct')

describe PStruct do

  before :each do
    @pfile = mock(:pfile, :write => nil)
    File.stub!(:open).and_yield(@pfile)
    @file = '/tmp/ps.yml'
    @hash = {:foo => :bar}
    YAML.stub!(:load_file).and_return(@hash)
    YAML.stub!(:dump)
  end

  describe 'initialize' do

    it 'should require a file argument' do
      lambda { PStruct.new }.should raise_error(ArgumentError)
    end

    it 'should accept a file argument' do
      lambda { PStruct.new(@file) }.should_not raise_error
    end

    it 'should accept an optional hash argument' do
      lambda { PStruct.new(@file, @hash) }.should_not raise_error
    end

    it 'should not commit when hash argument supplied' do
      File.should_receive(:open).never
      PStruct.new(@file, @hash)
    end

    it 'should not commit when hash argument not supplied' do
      File.should_receive(:open).never
      PStruct.new(@file)
    end

  end

  describe 'attribute' do

    before :each do
      @ps = PStruct.new(@file)
    end

    describe 'file' do

      it 'should have a getter' do
        @ps.respond_to?(:file).should be_true
      end
  
      it 'should have a setter' do
        @ps.respond_to?('file='.to_sym).should be_true
      end
  
      it 'should get the attribute' do
        @ps.file.should == @file
      end
  
      it 'should set the attribute' do
        @ps.file = 'foo'
        @ps.file.should == 'foo'
      end

    end

  end

  describe 'persistance' do

    describe 'load' do
      
      before :each do
        @ps = PStruct.new(@file)
      end

      it 'should load a YAML rep' do
        YAML.should_receive(:load_file).once
        @ps.load
      end

      it 'should read from the persistence file' do
        YAML.should_receive(:load_file).with(@file).once
        @ps.load
      end

      it 'should return the Hash rep' do
        @ps.load.should == @hash
      end

    end

    describe 'commit' do

      before :each do
        @ps = PStruct.new(@file, @hash)
      end

      it 'should dump the Hash rep' do
        YAML.should_receive(:dump).with(@hash, @pfile).once
        @ps.commit
      end

      it 'should write to the persistence file' do
        File.should_receive(:open).with(@file, 'w').once
        @ps.commit
      end

      it 'should return nil' do
        @ps.commit.should be_nil
      end

    end

    describe 'class load' do

      before :each do
        @ps = mock(:ps, :load => nil)
        PStruct.stub!(:new).and_return(@ps)
      end

      it 'should require a file argument' do
        lambda { PStruct.load }.should raise_error(ArgumentError)
      end

      it 'should accept a file argument' do
        lambda { PStruct.load(@file) }.should_not raise_error
      end

      it 'should instantiate a new object' do
        PStruct.should_receive(:new).with(@file).once
        PStruct.load(@file)
      end

      it 'should load the persistance file' do
        @ps.should_receive(:load).once
        PStruct.load(@file)
      end

      it 'should return the instantiated object' do
        PStruct.load(@file).should == @ps
      end

    end

    describe 'autocommit' do
      
      before :each do
        @ps = PStruct.new(@file, @hash)
      end

      it 'should commit after existing attr update' do
        @ps.should_receive(:commit).once
        @ps.foo = :baz
      end

      it 'should commit after new attr set' do
        @ps.should_receive(:commit).once
        @ps.bar = :baz
      end

      it 'should not commit after attr get' do
        @ps.should_receive(:commit).never
        @ps.foo
      end

      it 'should commit after attr delete' do
        @ps.should_receive(:commit).once
        @ps.delete_field(:foo)
      end

    end

  end

end
