class FoodItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :food
  belongs_to :order_item
  belongs_to :preparation
  belongs_to :cart_item
end