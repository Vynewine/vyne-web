require 'test_helper'

class PromotionalCodeTest < ActiveSupport::TestCase
  test 'Can find by code' do
    promotional_code = PromotionCode.find_by(code: 'JOE-SHMO')
    assert_equal('JOE-SHMO', promotional_code.code)
    assert_equal('wine', promotional_code.promotion.category)
  end

  test 'Will generate code based on first and last name on save when code not provided and not already used' do
    user = users(:one)
    promotion = promotions(:for_new_users)

    promotion_code = PromotionCode.create(
        :promotion => promotion,
        :category => PromotionCode.categories[:referral_code],
        :user => user,
        :active => true
    )

    assert_equal('JOHN-DOE', promotion_code.code)
  end

  test 'Will generate code based on first and 4 random characters on save when code already used' do
    user = users(:one)
    promotion = promotions(:for_new_users)

    PromotionCode.create(
        :promotion => promotion,
        :category => PromotionCode.categories[:referral_code],
        :user => user,
        :active => true
    )

    second_code = PromotionCode.new
    second_code.stubs(:generate_key).returns('ABCD')
    second_code.category = PromotionCode.categories[:referral_code]
    second_code.user = user
    second_code.save

    assert_equal('JOHN-ABCD', second_code.code)

  end

  test 'Will generate code based on first and user id on save when code already used' do
    user = users(:one)
    promotion = promotions(:for_new_users)

    PromotionCode.create(
        :promotion => promotion,
        :category => PromotionCode.categories[:referral_code],
        :user => user,
        :active => true
    )

    second_code = PromotionCode.new
    second_code.stubs(:generate_key).returns('ABCD')
    second_code.category = PromotionCode.categories[:referral_code]
    second_code.user = user
    second_code.save

    third_code = PromotionCode.new
    third_code.stubs(:generate_key).returns('ABCD')
    third_code.category = PromotionCode.categories[:referral_code]
    third_code.user = user
    third_code.save


    assert_equal("JOHN-#{user.id}", third_code.code)

  end

  test 'Will save and uppercase code that was provided' do

    promotion = promotions(:wine)

    promotion_code = PromotionCode.create(
        :promotion => promotion,
        :category => PromotionCode.categories[:vyne_code],
        :active => true,
        :code => 'nice-code'
    )

    assert_equal('NICE-CODE', promotion_code.code)
  end

  test 'Will remove white space from first name' do

    user = users(:one)
    user.first_name = 'Mikie Mike '
    promotion = promotions(:for_new_users)

    promotion_code = PromotionCode.create(
        :promotion => promotion,
        :category => PromotionCode.categories[:referral_code],
        :user => user,
        :active => true
    )

    assert_equal('MIKIEMIKE-DOE', promotion_code.code)

  end
end