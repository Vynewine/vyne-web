class Subregion < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :region
end
