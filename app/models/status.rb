class Status < ActiveRecord::Base
  acts_as_paranoid

  enum status: {
           pending: 1,
           paid: 2,
           payment_failed: 3,
           pickup: 4,
           in_transit: 5,
           delivered: 6,
           cancelled: 7,
           packing: 8,
           created: 10
       }

end