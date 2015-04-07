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

  test "Can't use expired promo codes" do
    promo_code = PromotionCode.find_by(code: 'VIP-VYNE-EX', active: true)
    assert_equal(1, promo_code.restrictions.length)
    assert_equal('Requested promotion code has expired.', promo_code.restrictions[0])
  end

  test 'Can find not expired promo code' do
    promo_code = PromotionCode.find_by(code: 'VIP-VYNE-CURRENT', active: true)
    assert_equal(0, promo_code.restrictions.length)
  end

  test "Can't use promo code with exhausted redeem limit" do
    promo_code = PromotionCode.find_by(code: 'VYNE-REDEEM-COUNT-EXCEEDED', active: true)
    assert_equal(1, promo_code.restrictions.length)
    assert_equal('Maximum redeem limit has been reached.', promo_code.restrictions[0])

  end

  test 'Can use promo code with not exhausted redeem limit' do
    promo_code = PromotionCode.find_by(code: 'VYNE-REDEEM-COUNT-NOT-EXCEEDED', active: true)
    assert_equal(0, promo_code.restrictions.length)
    assert_equal(promo_code, promotion_codes(:redeem_count_not_exceeded_promo_code))
  end

  test 'Can find referral code' do
    promo_code = PromotionCode.find_by(code: 'JOE-SHMO', active: true)
    assert_equal(promo_code, promotion_codes(:referral_one))
  end

  test 'Can find vyne code' do
    promo_code = PromotionCode.find_by(code: 'UNCORK', active: true)
    assert_equal(promo_code, promotion_codes(:vyne_uncork))
  end
end