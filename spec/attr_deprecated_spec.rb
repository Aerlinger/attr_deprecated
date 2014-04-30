require 'spec_helper'

class Foo
  include AttrDeprecated

  attr_accessor :fresh_attribute,
                :an_unused_attribute
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
    Foo.deprecated_attributes.should eq [:an_unused_attribute]
  end

  describe "A class includes AttrDeprecated" do
    before do
      @f = Foo.new
      @f.an_unused_attribute = "asdf"
      @f.fresh_attribute = "fresh"
    end

    describe "declaring an unused attribute as deprecated" do
      specify ".attr_deprecated? includes :an_unused_attribute" do
        Foo.deprecated_attribute?(:an_unused_attribute).should be_true
      end

      specify "A getter attribute is defined as deprecated" do
        @f.should_receive(:an_unused_attribute).exactly(1).times.and_call_original
        Foo.should_receive(:_notify_deprecated_attribute_call)

        @f.should_not_receive(:an_unused_attribute=)

        @f.an_unused_attribute.should eq("asdf")
      end

      specify "A setter attribute is defined as deprecated" do
        Foo.should_receive(:_notify_deprecated_attribute_call).exactly(2).times.and_call_original

        @f.an_unused_attribute = "omg"
        @f.an_unused_attribute
        @f.an_unused_attribute.should eq("omg")
      end

      specify "calling attr_deprecated more than once shouldn't cause infinite regress" do
        Foo.class_eval { attr_deprecated :an_unused_attribute }

        @f.an_unused_attribute.should eq("asdf")
      end
    end

    describe "Adding a new deprecated attribute (more than once)" do
      before do
        Foo.class_eval { attr_deprecated :fresh_attribute, :fresh_attribute}
      end

      it "only calls fresh_attribute once" do
        @f.should_receive(:fresh_attribute).exactly(1).times.and_call_original

        @f.fresh_attribute.should eq("fresh")
      end
    end

    describe "clearing deprecated attributes" do
      before do
        Foo.clear_deprecated_attributes!
      end

      it "Doesn't have any deprecated attributes" do
        Foo.deprecated_attributes.should eq([])
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
      @dummy_class.deprecated_attributes.should eq([])
    end

    it "calling attr_deprecated alone doesn't raise an error" do
      @dummy_class.class_eval do
        attr_deprecated
      end

      @dummy_class.deprecated_attributes.should eq([])
    end
  end
end
