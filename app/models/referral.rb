class Referral < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :promotion
  belongs_to :user
  belongs_to :referred_user, class_name: 'User'
  belongs_to :existing_user, class_name: 'User'
  belongs_to :promotion_code

  has_many :referral_codes


  validates :user, :presence => true
  validates :promotion, :presence => true

end