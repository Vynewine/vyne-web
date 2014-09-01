class Wine < ActiveRecord::Base

  belongs_to :producer
  belongs_to :subregion
  belongs_to :appellation
  belongs_to :maturation

  has_and_belongs_to_many :types
  # has_and_belongs_to_many :grapes
  has_and_belongs_to_many :occasions
  has_and_belongs_to_many :foods
  has_and_belongs_to_many :notes
  has_and_belongs_to_many :allergies

  attr_accessor :occasion_tokens
  attr_accessor :food_tokens
  attr_accessor :note_tokens

  def occasion_tokens=(ids)
    self.occasion_ids = ids.split(",")
  end
  def food_tokens=(ids)
    self.food_ids = ids.split(",")
  end
  def note_tokens=(ids)
    self.note_ids = ids.split(",")
  end

  has_many :compositions
  has_many :grapes, through: :compositions
  accepts_nested_attributes_for :compositions

end
