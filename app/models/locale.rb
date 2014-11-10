class Locale < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :subregion
end