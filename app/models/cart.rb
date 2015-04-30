class Cart < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :address
  belongs_to :warehouse

  has_many :cart_items

  enum delivery_type: [:live, :scheduled]

end
