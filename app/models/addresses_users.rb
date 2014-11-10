class AddressesUsers < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :address
  belongs_to :user
end
