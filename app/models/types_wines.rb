class TypesWines < ActiveRecord::Base
  belongs_to :type
  belongs_to :wine
end
