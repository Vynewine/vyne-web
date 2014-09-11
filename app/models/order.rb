class Order < ActiveRecord::Base
  belongs_to :address
  belongs_to :warehouse
  belongs_to :payment
  belongs_to :client, class_name: "User"
  belongs_to :advisor, class_name: "User"
  belongs_to :wine

  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true

  # def new_address_detail
  # end
  # def new_address_street
  # end
  # def new_address_postcode
  # end

end
