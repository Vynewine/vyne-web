class Grape < ActiveRecord::Base
  belongs_to :grapename
  has_and_belongs_to_many :wines
end
