class Wine < ActiveRecord::Base

  belongs_to :producer
  belongs_to :subregion
  belongs_to :appellation
  belongs_to :maturation

  has_many :types_wines, :class_name => 'TypesWines'
  has_many :types, :class_name => 'Type', :through => :types_wines
  accepts_nested_attributes_for :types, :reject_if => lambda { |a| a[:content].blank? }, :allow_destroy => false

  has_many :grapes_wines
  has_many :grapes, :through => :grapes_wines

  has_many :occasions_wines
  has_many :occasions, :through => :occasions_wines

  has_many :foods_wines
  has_many :foods, :through => :foods_wines

  has_many :notes_wines
  has_many :notes, :through => :notes_wines

  has_many :allergies_wines
  has_many :allergies, :through => :allergies_wines

end
