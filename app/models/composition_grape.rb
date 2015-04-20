class CompositionGrape < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :composition
  belongs_to :grape

  validates :grape_id, :composition_id, :presence => true
end