class AllergiesWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :allergy
end
