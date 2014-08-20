class OccasionsWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :wine_occasion
end
