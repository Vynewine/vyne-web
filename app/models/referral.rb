class Referral < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :referred_user, class_name: 'User'
  belongs_to :existing_user, class_name: 'User'
  belongs_to :promotion_code

  validates :referred_user, :presence => true
  validates :existing_user, :presence => true
  validates :promotion_code, :presence => true

end