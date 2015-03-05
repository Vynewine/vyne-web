class UserPromotion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  # Friend is assigned to UserPromotion record when it's a referral_reward record.
  # In case of new_account_reward record we can find out who sent it via referral_code association.
  belongs_to :friend, class_name: 'User'
  belongs_to :referral_code

  enum category: [:new_account_reward, :referral_reward]

  def add_referral_reward(friend, referral_code)

  end

  def add_new_account_reward(referral_code)

  end

end