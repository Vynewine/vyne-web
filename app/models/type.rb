class Type < ActiveRecord::Base
  has_many :types_wines
  has_many :wines, :through => :types_wines
end
