class WineNote < ActiveRecord::Base
  has_many :notes_wines
  has_many :wines, :through => :notes_wines
end
