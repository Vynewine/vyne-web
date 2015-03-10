require 'test_helper'

class WarehousePromotionTest < ActiveSupport::TestCase
  test 'Can use promotion price range' do

    warehouse = warehouses(:one)
    WarehousePromotion.create!(
        :warehouse => warehouse,
        :promotion => promotions(:wine),
        :active => true,
        :price_range => (5..10)
    )

    warehouse_promotion = WarehousePromotion.find_by(:warehouse => warehouse)

    assert_equal(warehouse, warehouse_promotion.warehouse)
    assert(warehouse_promotion.price_range.include?(5))
    assert_equal(5.0, warehouse_promotion.price_range.min)
    assert_equal(10.0, warehouse_promotion.price_range.max)
  end
end