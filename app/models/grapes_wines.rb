class GrapesWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :grape
end
