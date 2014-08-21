class Food < ActiveRecord::Base
  has_many :foods_wines
  has_many :wines, :through => :foods_wines
end
