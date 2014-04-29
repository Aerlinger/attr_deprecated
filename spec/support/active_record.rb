require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.verbose = false

class ActiveRecord::SchemaMigration < ActiveRecord::Base
end

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.string :email
    t.string :a_deprecated_attribute
    t.timestamps
  end
end
