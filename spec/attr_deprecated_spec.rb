require 'spec_helper'

class ModelWithDeprecatedAttrs
  include AttrDeprecated

  attr_accessor :fresh_attribute,
                :an_unused_attribute,
                :an_unused_method

  def an_unused_method(arg1)
    Logger.new(STDOUT).debug("CALL ORIGINAL an_unused_attribute")
  end

  attr_deprecated :an_unused_attribute, :an_unused_method
end

RSpec.describe "AttrDeprecated" do
  before do
    ActiveRecord::Base.logger ||= Logger.new(STDOUT)
  end

  describe "Configuration" do
    it "has correct default params" do
      expect(AttrDeprecated.configuration.enable).to be(true)
      expect(AttrDeprecated.configuration.raise).to be(false)
      expect(AttrDeprecated.configuration.rails_logger).to eql({ level: :debug, color: true })
    end

    it "allows configuration" do
      AttrDeprecated.configure do |config|
        config.enable       = false
        config.raise        = true
        config.rails_logger = { level: :error }
        config.slack        = { webhook_url: 'http://my.webhook', channel: '#my-channel', username: 'notifications' }
      end

      expect(AttrDeprecated.configuration.enable).to be(false)
      expect(AttrDeprecated.configuration.raise).to be(true)
      expect(AttrDeprecated.configuration.rails_logger).to eql({ level: :error })
    end
  end

  describe "AttrDeprecated model state" do
    specify "A class that extends AttrDeprecated::Model will have attr_deprecated defined" do
      expect(ModelWithDeprecatedAttrs.methods).to include(:attr_deprecated)
      expect(ModelWithDeprecatedAttrs.instance_methods).to include(:an_unused_method, :an_unused_attribute)
      expect(ModelWithDeprecatedAttrs.deprecated_attribute?(:an_unused_attribute)).to be
    end

    specify "includes deprecated attributes" do
      expect(ModelWithDeprecatedAttrs.deprecated_attributes).to eq [:an_unused_attribute, :an_unused_method]
    end

    specify "calling attr_deprecated more than once shouldn't cause infinite regress" do
      ModelWithDeprecatedAttrs.class_eval do
        def another_deprecated_attribute
          "foo"
        end

        attr_deprecated :another_deprecated_attribute
        attr_deprecated :another_deprecated_attribute
        attr_deprecated :another_deprecated_attribute
      end

      model = ModelWithDeprecatedAttrs.new
      
      expect(model).to receive(:another_deprecated_attribute).once.and_call_original

      expect(model.another_deprecated_attribute).to eq("foo")
    end

    describe "clearing deprecated attributes" do
      before do
        ModelWithDeprecatedAttrs.clear_deprecated_attributes!
      end

      it "Doesn't have any deprecated attributes" do
        expect(ModelWithDeprecatedAttrs.deprecated_attributes).to eq([])
      end
    end

    describe "A class doesn't have any deprecated attributes initially" do
      before do
        @dummy_class = Class.new do
          include AttrDeprecated
        end
      end

      it "has empty deprecated attributes" do
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

  describe "calling methods" do
    before do
      @f = ModelWithDeprecatedAttrs.new
      @f.an_unused_attribute = "asdf"
      @f.fresh_attribute = "fresh"
    end

    it "getter attribute is defined as deprecated" do
      expect(@f).to receive(:an_unused_attribute).exactly(1).times.and_call_original
      expect(ModelWithDeprecatedAttrs).to receive(:_notify_deprecated_attribute_call)

      expect(@f).to_not receive(:an_unused_attribute=)

      expect(@f.an_unused_attribute).to eq("asdf")
    end

    specify "A setter attribute is defined as deprecated" do
      expect(ModelWithDeprecatedAttrs).to receive(:_notify_deprecated_attribute_call).exactly(2).times.and_call_original

      @f.an_unused_attribute = "omg"
      @f.an_unused_attribute
      expect(@f.an_unused_attribute).to eq("omg")
    end

    it "Adding a new deprecated attribute (more than once) only calls fresh_attribute once" do
      ModelWithDeprecatedAttrs.class_eval { attr_deprecated :fresh_attribute, :fresh_attribute }

      expect(@f).to receive(:fresh_attribute).exactly(1).times.and_call_original

      expect(@f.fresh_attribute).to eq("fresh")
    end
  end
end
