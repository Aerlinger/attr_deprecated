require 'spec_helper'

class Foo
  attr_accessor :fresh_attribute, :an_unused_attribute
end


describe "Sample spec" do
  specify "AttrDeprecated is defined" do
    defined?(AttrDeprecated).should be_true
  end

  describe "A class includes AttrDeprecated" do
    before do
      Foo.class_eval { include AttrDeprecated }

      @f = Foo.new
      @f.an_unused_attribute = "asdf"
    end

    specify "A class that extends AttrDeprecated::Model will have attr_deprecated defined" do
      Foo.methods.should include(:attr_deprecated)
    end

    specify "An attribute is defined as deprecated" do
      Foo.class_eval { attr_deprecated :an_unused_attribute }
      @f.methods.should include(:_an_unused_attribute_deprecated)

      @f.an_unused_attribute.should eq("asdf")
    end
  end

end
