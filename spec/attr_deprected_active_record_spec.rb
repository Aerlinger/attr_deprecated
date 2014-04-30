require 'spec_helper'

describe "Integration with ActiveRecord" do
  before do
    ActiveRecord::Base.send(:descendants).each do |klass|
      begin
        klass.delete_all
      rescue
      end
    end
  end

  let!(:user) { User.new(name: "rspec", a_deprecated_attribute: "wtf") }

  it "has :a_deprecated_attribute method" do
    class User < ActiveRecord::Base
      attr_deprecated :a_deprecated_attribute
    end

    User.instance_methods.should include(:a_deprecated_attribute)
  end

  it "ensures we've initialized ActiveRecord correctly for our test suite" do
    user.save!

    expect(user.persisted?).to be_true
    expect(user.a_deprecated_attribute).to eq("wtf")
  end

  it "has one deprecated attribute" do
    expect(User.deprecated_attributes).to eq([:a_deprecated_attribute])
  end
end
