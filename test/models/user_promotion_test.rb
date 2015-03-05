require 'test_helper'

class UserPromotionTest < ActiveSupport::TestCase
  test 'Can create referral reward user promotion' do
    user = users(:one)
    friend = users(:two)

    referral_code = referral_codes(:abc)

    puts json: referral_code

    UserPromotion.create!({
                              user: user,
                              referral_code: referral_code,
                              category: UserPromotion.categories[:referral_reward],
                              friend: friend
                          })

    user_promotion = UserPromotion.where(:user => user, :friend => friend)

    assert(1, user_promotion.length)
    assert_equal(user, user_promotion.first.user)
    assert_equal(friend, user_promotion.first.friend)


  end
end