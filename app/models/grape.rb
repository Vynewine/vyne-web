class Grape < ActiveRecord::Base
  acts_as_paranoid
  validates :name, :presence => true
  validates :name, :uniqueness => true
end
