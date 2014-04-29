require 'spec_helper'

class User < ActiveRecord::Base
  include AttrDeprecated

  attr_deprecated :a_deprecated_attribute
end

describe "Integration with ActiveRecord" do
  let(:user) { User.new(name: "rspec") }

  it "ensures we've initialized ActiveRecord correctly for our test suite" do
    user.save!

    expect(user.persisted?).to be_true
    expect(user.a_deprecated_attribute).to be_blank
  end

  it "has one deprecated attribute" do
    expect(User.deprecated_attributes).to eq([])
  end
end
