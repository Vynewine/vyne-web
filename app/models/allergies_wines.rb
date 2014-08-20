class AllergiesWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :wine_allergy
end
