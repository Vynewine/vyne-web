class UserPromotion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  # Friend is assigned to UserPromotion record when it's a referral_reward record.
  # In case of new_account_reward record we can find out who sent it via referral_code association.
  belongs_to :friend, class_name: 'User'
  belongs_to :referral_code

  enum category: [:sign_up_reward, :sharing_reward]

  validate :eligible_for_promotions, on: :create

  def self.new_account_reward(referral_code, user)

    sign_up_promo = create({
                               :user => user,
                               :referral_code => referral_code,
                               :category => self.categories[:sign_up_reward],
                               :can_be_redeemed => true
                           })

    unless sign_up_promo.errors.blank?
      return sign_up_promo.errors.full_messages
    end

    share_promo = create({
               :user => referral_code.referral.user,
               :friend => user,
               :referral_code => referral_code,
               :category => self.categories[:sharing_reward]
           })

    unless share_promo.errors.blank?
      return share_promo.errors.full_messages
    end
  end

  def eligible_for_promotions
    if self.sign_up_reward?
      if user == referral_code.referral.user
        errors[:base] << "You can't use our own promo code"
      end

      existing_promotion = UserPromotion.find_by(:user => user, :category => category)

      unless existing_promotion.blank?
        errors[:base] << 'The same promotion is already associated with your account'
      end
    end
  end
end