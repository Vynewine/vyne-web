class CartItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :cart
end