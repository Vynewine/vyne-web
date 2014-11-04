class FoodItem < ActiveRecord::Base
  belongs_to :food
  belongs_to :order_item
  belongs_to :preparation
end