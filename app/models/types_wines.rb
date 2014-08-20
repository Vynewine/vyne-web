class TypesWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :wine_type
end
