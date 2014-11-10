class Producer < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :country
end
