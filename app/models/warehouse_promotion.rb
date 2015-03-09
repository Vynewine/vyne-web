class WarehousePromotion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :warehouse
  belongs_to :promotion

  validates_uniqueness_of :warehouse_id, :scope => :promotion_id
end