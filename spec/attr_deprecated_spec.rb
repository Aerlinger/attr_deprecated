require 'spec_helper'

class Foo
  include AttrDeprecated

  attr_accessor :fresh_attribute, :an_unused_attribute
  attr_deprecated :an_unused_attribute
end

describe "Sample spec" do
  specify "AttrDeprecated is defined" do
    defined?(AttrDeprecated).should be_true
  end

  specify "A class that extends AttrDeprecated::Model will have attr_deprecated defined" do
    Foo.methods.should include(:attr_deprecated)
  end

  it "has attr deprecated" do
    Foo.attrs_deprecated.should eq [:an_unused_attribute]
  end

  describe "A class includes AttrDeprecated" do
    before do
      @f = Foo.new
      @f.an_unused_attribute = "asdf"
      @f.fresh_attribute = "fresh"
    end

    describe "declaring an unused attribute as deprecated" do
      it "has correct shadow methods" do
        @f.methods.should include(:__deprecated_an_unused_attribute)
        @f.methods.should include(:__deprecated_an_unused_attribute=)
      end

      specify "A getter attribute is defined as deprecated" do
        @f.should_receive(:an_unused_attribute).exactly(1).times.and_call_original
        @f.should_receive(:__deprecated_an_unused_attribute).exactly(1).times.and_call_original

        @f.should_not_receive(:__deprecated_an_unused_attribute=)
        @f.should_not_receive(:an_unused_attribute=)

        @f.an_unused_attribute.should eq("asdf")
      end

      specify "A setter attribute is defined as deprecated" do
        @f.should_receive(:__deprecated_an_unused_attribute=).exactly(1).times.and_call_original
        #@f.should_not_receive(:__deprecated_an_unused_attribute)
        #@f.should_not_receive(:an_unused_attribute)

        @f.an_unused_attribute = "omg"
        @f.an_unused_attribute.should eq("omg")
      end

      specify "calling attr_deprecated more than once shouldn't cause infinite regress" do
        Foo.class_eval { attr_deprecated :an_unused_attribute }
        #@f.an_unused_attribute.should eq("omg")
      end
    end
  end
end
