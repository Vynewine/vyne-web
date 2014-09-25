class Inventory < ActiveRecord::Base
  belongs_to :warehouse
  belongs_to :wine
end
