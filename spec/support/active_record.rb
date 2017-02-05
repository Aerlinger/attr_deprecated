require 'attr_deprecated'
require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.string :a_deprecated_attribute
    t.timestamps
  end
end

class User < ActiveRecord::Base
end
