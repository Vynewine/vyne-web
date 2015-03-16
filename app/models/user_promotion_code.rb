class UserPromotionCode < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :promotion_code

end
