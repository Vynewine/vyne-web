class Composition < ActiveRecord::Base
  belongs_to :grape
  has_and_belongs_to_many :wines
end
