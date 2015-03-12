class AddUserPromotionsForExistingUsers < ActiveRecord::Migration
  def change

    referral_code = ReferralCode.find_by(code: 'VYNEHEROES')

    unless referral_code.blank?

      users = User.all.select do |user|
        user.user_promotions.blank?
      end

      users.each do |user|

        unless user == referral_code.referral.user

          UserPromotion.create!({
                                    :user => user,
                                    :referral_code => referral_code,
                                    :category => UserPromotion.categories[:sign_up_reward],
                                    :can_be_redeemed => true
                                })

          if user.referrals.blank?
            new_referral = Referral.create!(
                :user => user,
                :promotion => referral_code.referral.promotion
            )

            ReferralCode.create!(
                :referral => new_referral
            )
          end
        end
      end
    end
  end
end
