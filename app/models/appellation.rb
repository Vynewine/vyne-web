class Appellation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :region
  validates :name, :region_id, :presence => true
end
