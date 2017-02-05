require 'spec_helper'

class Foo
  include AttrDeprecated

  attr_accessor :fresh_attribute,
                :an_unused_attribute
  attr_deprecated :an_unused_attribute
end

RSpec.describe "Sample spec" do
  specify "AttrDeprecated is defined" do
    expect(defined?(AttrDeprecated)).to be
  end

  specify "A class that extends AttrDeprecated::Model will have attr_deprecated defined" do
    expect(Foo.methods).to include(:attr_deprecated)
  end

  it "has attr deprecated" do
    expect(Foo.deprecated_attributes).to eq [:an_unused_attribute]
  end

  describe "A class includes AttrDeprecated" do
    before do
      @f = Foo.new
      @f.an_unused_attribute = "asdf"
      @f.fresh_attribute = "fresh"
    end

    describe "declaring an unused attribute as deprecated" do
      specify ".attr_deprecated? includes :an_unused_attribute" do
        expect(Foo.deprecated_attribute?(:an_unused_attribute)).to be
      end

      specify "A getter attribute is defined as deprecated" do
        expect(@f).to receive(:an_unused_attribute).exactly(1).times.and_call_original
        expect(Foo).to receive(:_notify_deprecated_attribute_call)

        expect(@f).to_not receive(:an_unused_attribute=)

        expect(@f.an_unused_attribute).to eq("asdf")
      end

      specify "A setter attribute is defined as deprecated" do
        expect(Foo).to receive(:_notify_deprecated_attribute_call).exactly(2).times.and_call_original

        @f.an_unused_attribute = "omg"
        @f.an_unused_attribute
        expect(@f.an_unused_attribute).to eq("omg")
      end

      specify "calling attr_deprecated more than once shouldn't cause infinite regress" do
        Foo.class_eval { attr_deprecated :an_unused_attribute }

        expect(@f.an_unused_attribute).to eq("asdf")
      end
    end

    describe "Adding a new deprecated attribute (more than once)" do
      before do
        Foo.class_eval { attr_deprecated :fresh_attribute, :fresh_attribute}
      end

      it "only calls fresh_attribute once" do
        expect(@f).to receive(:fresh_attribute).exactly(1).times.and_call_original

        expect(@f.fresh_attribute).to eq("fresh")
      end
    end

    describe "clearing deprecated attributes" do
      before do
        Foo.clear_deprecated_attributes!
      end

      it "Doesn't have any deprecated attributes" do
        expect(Foo.deprecated_attributes).to eq([])
      end
    end
  end

  describe "A class doesn't have any deprecated attributes initially" do
    before do
      @dummy_class = Class.new do
        include AttrDeprecated
      end
    end

    it "empty deprecated attributes" do
      expect(@dummy_class.deprecated_attributes).to eq([])
    end

    it "calling attr_deprecated alone doesn't raise an error" do
      @dummy_class.class_eval do
        attr_deprecated
      end

      expect(@dummy_class.deprecated_attributes).to eq([])
    end
  end
end
