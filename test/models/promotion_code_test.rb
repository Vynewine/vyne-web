require 'test_helper'

class PromotionCodeTest < ActiveSupport::TestCase
  test 'Can find promotion code' do
    promotion_code = PromotionCode.find_by(code: promotion_codes(:vyne_uncork).code)
    assert_equal('UNCORK', promotion_code.code)
  end

  test "Can't create multiple promo codes with the same code" do
    PromotionCode.create!(
        :code => 'ABC',
        :category => PromotionCode.categories[:vyne_code]
    )

    existing_code = PromotionCode.new(
        :code => 'ABC',
        :category => PromotionCode.categories[:vyne_code]
    )

    existing_code.save

    assert_equal('Code has already been taken', existing_code.errors.full_messages[0])
  end

end