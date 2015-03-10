require 'test_helper'

class UserPromotionTest < ActiveSupport::TestCase

  test 'Will create new account and sharing rewards' do
    user = users(:one)
    friend = users(:client)

    referral_code = referral_codes(:abc)

    UserPromotion.new_account_reward(referral_code, user)

    user_promotions = UserPromotion.where(:referral_code => referral_code)

    assert_equal(2, user_promotions.count)

    new_account_reward = user_promotions.select{|promo| promo.user == user}.first
    sharing_reward = user_promotions.select{|promo| promo.user == friend}.first

    assert(new_account_reward.sign_up_reward?)
    assert_equal(user, new_account_reward.user)
    assert_equal(referral_code, new_account_reward.referral_code)

    assert(sharing_reward.sharing_reward?)
    assert_equal(friend, sharing_reward.user)
    assert_equal(referral_code, sharing_reward.referral_code)

  end

  test 'Only ine sign-up promotion can be applied to accoint' do
    user = users(:one)

    referral_code = referral_codes(:abc)

    UserPromotion.new_account_reward(referral_code, user)

    error = UserPromotion.new_account_reward(referral_code, user)

    user_promotions = UserPromotion.where(:referral_code => referral_code)

    assert_equal(2, user_promotions.count, 'One sign-up and one sharing promotion should be created for this code')
    assert_equal('The same promotion is already associated with your account',error.first)

  end

  test 'Multiple sharing rewards can be applied to a user' do
    user_one = users(:one)
    user_two = users(:two)
    existing_user = users(:client)

    referral_code = referral_codes(:abc)

    UserPromotion.new_account_reward(referral_code, user_one)
    UserPromotion.new_account_reward(referral_code, user_two)

    user_promotions = UserPromotion.where(:referral_code => referral_code)

    assert_equal(4, user_promotions.count)
    assert_equal(1, user_promotions.select{|promo| promo.user == user_one}.count)
    assert(user_promotions.select{|promo| promo.user == user_one}.first.sign_up_reward?)

    assert_equal(1, user_promotions.select{|promo| promo.user == user_two}.count)
    assert(user_promotions.select{|promo| promo.user == user_two}.first.sign_up_reward?)

    assert_equal(2, user_promotions.select{|promo| promo.user == existing_user}.count)
    user_promotions.select{|promo| promo.user == existing_user}.each{|promo| assert(promo.sharing_reward?)}
  end

end