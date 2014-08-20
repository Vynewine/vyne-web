class WineOccasion < ActiveRecord::Base
  has_many :occasions_wines
  has_many :wines, :through => :occasions_wines
end
