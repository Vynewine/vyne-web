require 'test_helper'

class ReferralCodeTest < ActiveSupport::TestCase
  test 'Can find by code' do
    referral_code = ReferralCode.find_by(code: 'ABC')
    assert_equal('ABC', referral_code.code)
    assert_equal('wine', referral_code.referral.promotion.category)
  end

  test 'Will generate code based on first and last name on save when code not provided and not already used' do
    referral = referrals(:one)

    referral_code = ReferralCode.create(
        :referral => referral
    )

    assert_equal('JOHN-DOE', referral_code.code)
  end

  test 'Will generate code based on first and 4 random characters on save when code already used' do
    referral = referrals(:one)

    ReferralCode.create(
        :referral => referral
    )

    second_code = ReferralCode.new
    second_code.stubs(:generate_key).returns('ABCD')
    second_code.referral = referral
    second_code.save

    assert_equal('JOHN-ABCD', second_code.code)

  end

  test 'Will generate code based on first and user id on save when code already used' do
    referral = referrals(:one)

    ReferralCode.create(
        :referral => referral
    )

    second_code = ReferralCode.new
    second_code.stubs(:generate_key).returns('ABCD')
    second_code.referral = referral
    second_code.save

    third_code = ReferralCode.new
    third_code.stubs(:generate_key).returns('ABCD')
    third_code.referral = referral
    third_code.save

    assert_equal("JOHN-#{referral.user.id}", third_code.code)

  end

  test 'Will save and uppercase code that was provided' do
    referral = referrals(:one)

    referral_code = ReferralCode.create(
        :referral => referral,
        :code => 'nice-code'
    )

    assert_equal('NICE-CODE', referral_code.code)
  end

  test 'Will remove white space from first name' do
    referral = referrals(:one)

    referral.user.first_name = 'Mikie Mike'

    referral_code = ReferralCode.create(
        :referral => referral
    )

    assert_equal('MIKIEMIKE-DOE', referral_code.code)

  end
end