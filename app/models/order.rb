class Order < ActiveRecord::Base
  belongs_to :status
  belongs_to :address
  belongs_to :warehouse
  belongs_to :payment
  belongs_to :client, class_name: "User"
  belongs_to :advisor, class_name: "User"
  has_many :order_items

  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true

  scope :valid, -> { where.not(:wine_id => nil) }
  scope :user_id, ->(id) { where("client_id = ?", id) }

  def delivery_status_json
    d = delivery_status.to_s
    require 'pp'
    PP.pp(d,'',80)
  end

end
