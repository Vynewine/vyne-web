class ReferralCode < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :referral

  validates :code, uniqueness: true, promo_code: true

  before_create :generate_user_code

  def generate_user_code

    if self.code.blank?

      first_name = ''

      unless referral.user.first_name.blank?
        first_name = referral.user.first_name.gsub(/\s+/, '')
      end

      if first_name.blank? || referral.user.last_name.blank?
        if referral.user.last_name.blank? && !first_name.blank?
          new_code = "#{first_name}-#{generate_key}".upcase
        else
          new_code = generate_key.upcase
        end
      else
        new_code = "#{first_name}-#{referral.user.last_name[0..3]}".upcase
      end

      existing_code = ReferralCode.find_by(:code => new_code)

      unless existing_code.blank?
        new_code = "#{first_name}-#{generate_key}".upcase

        existing_code = ReferralCode.find_by(:code => new_code)

        unless existing_code.blank?
          new_code = "#{first_name}-#{referral.user.id}".upcase
        end
      end

      self.code = new_code
    else
      self.code = self.code.upcase
    end

  end

  def generate_key
    rand(36**4).to_s(36)
  end

end