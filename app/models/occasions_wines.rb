class OccasionsWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :occasion
end
