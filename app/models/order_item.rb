class OrderItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :order
  belongs_to :wine
  belongs_to :occasion
  belongs_to :type
  belongs_to :category
  has_many :food_items
end