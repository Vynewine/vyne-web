class PromotionCode < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :promotion
  belongs_to :user

  enum category: [:vyne_code, :referral_code]

  before_validation :uppercase_code

  validates :code, uniqueness: true, promo_code: true

  validates :code, presence: true, on: :update

  before_create :generate_promo_code

  def uppercase_code
    unless self.code.blank?
      self.code = self.code.upcase
    end
  end

  def generate_promo_code

    if self.code.blank? && self.referral_code?

      if self.user.blank?
        logger.error "User can't be blank for referral code"
      end

      first_name = ''

      unless user.first_name.blank?
        first_name = user.first_name.gsub(/\s+/, '')
      end

      if first_name.blank? || user.last_name.blank?
        if user.last_name.blank? && !first_name.blank?
          new_code = "#{first_name}-#{generate_key}".upcase
        else
          new_code = generate_key.upcase
        end
      else
        new_code = "#{first_name}-#{user.last_name[0..3]}".upcase
      end

      existing_code = PromotionCode.find_by(:code => new_code)

      unless existing_code.blank?
        new_code = "#{first_name}-#{generate_key}".upcase

        existing_code = PromotionCode.find_by(:code => new_code)

        unless existing_code.blank?
          new_code = "#{first_name}-#{user.id}".upcase
        end
      end

      self.code = new_code
    end

  end

  def generate_key
    rand(36**4).to_s(36)
  end
end
