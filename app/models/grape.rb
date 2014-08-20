class Grape < ActiveRecord::Base
  belongs_to :grapename
  has_many :grapes_wines
  has_many :wines, :through => :grapes_wines
end
