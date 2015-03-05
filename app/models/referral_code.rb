class ReferralCode < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :referral
end