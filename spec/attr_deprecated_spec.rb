require 'spec_helper'

describe "Sample spec" do
  specify "AttrDeprecated is defined" do
    defined?(AttrDeprecated).should be_true
  end

  specify "A class that extends AttrDeprecated::Model will have attr_deprecated defined" do
    Foo = Class.new

    Foo.class_eval { include AttrDeprecated::Model }

    Foo.methods.should include(:attr_deprecated)
  end
end
