class Producer < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :country

  validates :name, :country_id, :presence => true
end
