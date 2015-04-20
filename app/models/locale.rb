class Locale < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :subregion
  validates :name, :subregion_id, :presence => true
end