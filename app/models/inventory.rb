class Inventory < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :warehouse
  belongs_to :wine
  belongs_to :category
end
