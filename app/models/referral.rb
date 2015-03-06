class Referral < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :promotion
  belongs_to :user

  has_many :referral_codes

  validates :user, :presence => true

end