class CompositionGrape < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :composition
  belongs_to :grape
end