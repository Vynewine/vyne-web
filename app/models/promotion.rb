class Promotion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :bottle_category, class_name: 'Category'

  enum category: [:wine]

  validates :title, :presence => true

end