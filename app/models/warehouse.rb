class Warehouse < ActiveRecord::Base
  belongs_to :address
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
end
