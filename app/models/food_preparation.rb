class FoodPreparation < ActiveRecord::Base
  belongs_to :food
  belongs_to :preparation
end