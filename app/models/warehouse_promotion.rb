class WarehousePromotion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :warehouse
  belongs_to :promotion

  validates_uniqueness_of :warehouse_id, :scope => :promotion_id

  def to_s
    unless extra_bottle_price_min.blank? || extra_bottle_price_max.blank?
      "Price range: £#{'%.2f' % extra_bottle_price_min}-#{'%.2f' % extra_bottle_price_max}"
    end
  end
end