describe Solargraph::Source::Fragment do
  before :all do
    @call_source = Solargraph::Source.new("@foo = foo.bar(one, :two){|baz| puts 'hello'")
    @name_source = Solargraph::Source.new(%(
      class Foo
        def bar
          @bar
        end
        def self.baz
          @baz
        end
      end
    ))
  end

  it "accepts arrays or positions" do
    f1 = described_class.new(@call_source, [0, 2])
    f2 = described_class.new(@call_source, Solargraph::Source::Position.new(0, 2))
    expect(f1.word).to eq(f2.word)
    expect(f1.range).to eq(f2.range)
    expect(f1.context).to eq(f2.context)
  end

  it "get the position's word" do
    fragment = described_class.new(@call_source, [0, 2])
    expect(fragment.word).to eq('@foo')
  end

  it "gets the start of the word" do
    fragment = described_class.new(@call_source, [0, 2])
    expect(fragment.start_of_word).to eq('@f')
  end

  it "gets the end of the word" do
    fragment = described_class.new(@call_source, [0, 2])
    expect(fragment.end_of_word).to eq('oo')
  end

  it "gets the context of the root" do
    fragment = described_class.new(@name_source, [1, 0])
    expect(fragment.context.namespace).to eq('')
    expect(fragment.context.scope). to eq(:class)
  end

  it "gets the context inside a class" do
    fragment = described_class.new(@name_source, [2, 0])
    expect(fragment.context.namespace).to eq('Foo')
    expect(fragment.context.scope).to eq(:class)
  end

  it "gets the context inside an instance method" do
    fragment = described_class.new(@name_source, [3, 0])
    expect(fragment.context.namespace).to eq('Foo')
    expect(fragment.context.scope).to eq(:instance)
  end

  it "gets the context inside a class method" do
    fragment = described_class.new(@name_source, [6, 0])
    expect(fragment.context.namespace).to eq('Foo')
    expect(fragment.context.scope).to eq(:class)
  end

  it "recognizes symbols" do
    fragment = described_class.new(@call_source, [0, 21])
    expect(fragment.word).to eq(':two')
  end

  it "finds word ranges" do
    fragment = described_class.new(@call_source, [0, 8])
    expect(@call_source.at(fragment.range)).to eq('foo')
  end

  it "generates chains" do
    fragment = described_class.new(@call_source, [0, 12])
    expect(fragment.chain).to be_a(Solargraph::Source::Chain)
  end
end
