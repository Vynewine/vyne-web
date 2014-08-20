class WineAllergy < ActiveRecord::Base
  has_many :allergies_wines
  has_many :wines, :through => :allergies_wines
end
