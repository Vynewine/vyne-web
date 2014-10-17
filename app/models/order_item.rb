class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :wine
  belongs_to :occasion
  belongs_to :type
  has_and_belongs_to_many :foods
end