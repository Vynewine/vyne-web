class ReferralCode < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :referral

  validates :code, uniqueness: true, promo_code: true

  before_create :generate_user_code

  def generate_user_code
    new_code = "#{referral.user.first_name}-#{referral.user.last_name[0..3]}".upcase

    existing_code = ReferralCode.find_by(:code => new_code)

    unless existing_code.blank?
      new_code = "#{referral.user.first_name}-#{generate_key}".upcase

      existing_code = ReferralCode.find_by(:code => new_code)

      unless existing_code.blank?
        new_code = "#{referral.user.first_name}-#{referral.user.id}".upcase
      end
    end

    self.code = new_code
  end

  def generate_key
    rand(36**4).to_s(36)
  end

end