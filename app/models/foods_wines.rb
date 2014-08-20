class FoodsWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :wine_food
end
