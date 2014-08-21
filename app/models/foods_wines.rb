class FoodsWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :food
end
