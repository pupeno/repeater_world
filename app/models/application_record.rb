class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def to_s(extra = nil)
    if extra
      extra = ":#{extra}"
    end
    "#<#{self.class.name}:#{id}#{extra}>"
  end
end
