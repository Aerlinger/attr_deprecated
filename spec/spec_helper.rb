require 'bundler/setup'
Bundler.setup

ENV['test'] = 'test'

require 'attr_deprecated'
require 'support/active_record'

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
