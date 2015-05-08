class CartItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :cart

  has_many :food_items
end