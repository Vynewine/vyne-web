class ReferralCode < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :referral

  validates :code, uniqueness: true, promo_code: true

end