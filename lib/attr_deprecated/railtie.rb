require 'railtie'

module AttrDeprecated
  class Railtie < ::Rails::Railtie
    initializer "attr_deprecated.active_record", :before => "active_record.set_configs" do |app|
      ActiveSupport.on_load :active_record do
        if app.config.respond_to?(:active_record)
          class ActiveRecord::Base
            include AttrDeprecated
          end
        end
      end
    end
  end
end
