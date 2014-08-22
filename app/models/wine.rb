class Wine < ActiveRecord::Base

  belongs_to :producer
  belongs_to :subregion
  belongs_to :appellation
  belongs_to :maturation

  has_and_belongs_to_many :types
  has_and_belongs_to_many :grapes
  has_and_belongs_to_many :occasions
  has_and_belongs_to_many :foods
  has_and_belongs_to_many :notes
  has_and_belongs_to_many :allergies

end
