require 'test_helper'

class ReferralCodeTest < ActiveSupport::TestCase
  test 'Can find by code' do
    referral_code = ReferralCode.find_by(code: 'ABC')
    assert_equal('ABC', referral_code.code)
    assert_equal('wine', referral_code.referral.promotion.category)
  end
end