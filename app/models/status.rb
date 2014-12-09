class Status < ActiveRecord::Base
  acts_as_paranoid

  enum status: { pending: 1, paid: 2, payment: 3, pickup: 4, delivery: 5, delivered: 6, cancelled: 7, packing: 8 }

end
