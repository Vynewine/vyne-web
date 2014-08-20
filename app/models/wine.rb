class Wine < ActiveRecord::Base

  belongs_to :producer
  belongs_to :subregion
  belongs_to :appellation
  belongs_to :wine_maturation

  has_many :types_wines
  has_many :wine_types, :through => :types_wines

  has_many :grapes_wines
  has_many :wine_grapes, :through => :grapes_wines

  has_many :occasions_wines
  has_many :wine_occasions, :through => :occasions_wines

  has_many :foods_wines
  has_many :wine_foods, :through => :foods_wines

  has_many :notes_wines
  has_many :wine_notes, :through => :notes_wines

  has_many :allergies_wines
  has_many :wine_allergies, :through => :allergies_wines

end
