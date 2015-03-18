require 'test_helper'

class UserPromotionCodeTest < ActiveSupport::TestCase
  test 'Can find user promotion code' do
    user_promotion_code = UserPromotionCode.find_by(user: users(:client))
    assert_equal('JOE-SHMO', user_promotion_code.promotion_code.code)
  end
end