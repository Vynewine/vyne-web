class Composition < ActiveRecord::Base
  acts_as_paranoid

  has_many :composition_grapes
end