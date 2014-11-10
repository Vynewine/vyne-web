class Maturation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :bottling
end
