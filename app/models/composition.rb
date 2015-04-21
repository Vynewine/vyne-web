class Composition < ActiveRecord::Base
  acts_as_paranoid

  has_many :composition_grapes

  def to_s
    text = []
    composition_grapes.each do |composition|
      text << composition.grape.name + (composition.percentage.blank? ? '' : ' (' + composition.percentage.to_s + '%)')
    end

    text.join(', ')
  end

  def details
    "#{id} - #{to_s}"
  end

end