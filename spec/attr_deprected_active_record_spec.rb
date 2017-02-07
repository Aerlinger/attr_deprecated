require 'spec_helper'

class User < ActiveRecord::Base
  attr_deprecated :a_deprecated_attribute
end

RSpec.describe "Integration with ActiveRecord" do
  before do
    ActiveRecord::Base.send(:descendants).each do |klass|
      begin
        klass.delete_all
      rescue
      end
    end
  end

  let!(:user) { User.new(name: "rspec", a_deprecated_attribute: "this_is_deprecated") }

  it "has :a_deprecated_attribute method" do
    expect(User.instance_methods).to include(:a_deprecated_attribute)
  end

  it "ensures we've initialized ActiveRecord correctly for our test suite" do
    user.save!

    expect(user.persisted?).to be
    expect(user.a_deprecated_attribute).to eq("this_is_deprecated")
  end

  it "has one deprecated attribute" do
    expect(User.deprecated_attributes).to eq([:a_deprecated_attribute])
  end
end
