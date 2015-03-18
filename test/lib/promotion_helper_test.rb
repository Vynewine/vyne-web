require 'test_helper'

class PromotionHelperTest < ActiveSupport::TestCase

  test 'Can add promotion for a user' do
    new_user = users(:one)
    promo_code = promotion_codes(:referral_one)

    PromotionHelper.add_promotion(new_user, promo_code.code)

    new_user_promotions = UserPromotion.where(:user => new_user)
    existing_user_promotions = UserPromotion.where(:user => promo_code.user)

    assert_equal(1, new_user_promotions.count)
    assert_equal(promo_code, new_user_promotions.first.promotion_code)
    assert_equal(new_user, new_user_promotions.first.user)
    assert_equal(false, new_user_promotions.first.redeemed)
    assert_equal(true, new_user_promotions.first.can_be_redeemed)

    assert_equal(1, existing_user_promotions.count)
    assert_equal(promo_code, existing_user_promotions.first.promotion_code)
    assert_equal(promo_code.user, existing_user_promotions.first.referral.existing_user)
    assert_equal(new_user, existing_user_promotions.first.referral.referred_user)
    assert_equal(promo_code, existing_user_promotions.first.referral.promotion_code)
    assert_equal(false, existing_user_promotions.first.redeemed)
    assert_equal(false, existing_user_promotions.first.can_be_redeemed)
  end

  test 'Can enable referral promotion for a user' do
    user = users(:one)
    PromotionHelper.enable_referral_promotion(user)
    assert_equal(1, user.promotion_codes.count)
    assert_equal('JOHN-DOE', user.promotion_codes.first.code)
  end

end