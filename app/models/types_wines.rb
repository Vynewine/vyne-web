class TypesWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :type
end
