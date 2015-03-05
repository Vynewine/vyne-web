class Promotion < ActiveRecord::Base
  acts_as_paranoid

  enum category: [:wine]
end