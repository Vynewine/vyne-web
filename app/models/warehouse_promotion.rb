class WarehousePromotion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :warehouse
  belongs_to :promotion

  validates_uniqueness_of :warehouse_id, :scope => :promotion_id

  def to_s
    unless price_range_min.blank? || price_range_max.blank?
      "Price range: £#{'%.2f' % price_range_min}-#{'%.2f' % price_range_max}"
    end
  end
end