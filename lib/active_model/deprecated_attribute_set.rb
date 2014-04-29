require 'set'

module AttrDeprecated
  class DeprecatedAttributeSet < Set
    def ==(other_set)
      Set.new(self) == Set.new(other_set)
    end
  end
end
