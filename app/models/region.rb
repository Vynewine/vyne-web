class Region < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :country
  belongs_to :appellation

  validates :name, :country_id, :presence => true
end
