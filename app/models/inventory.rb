class Inventory < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :warehouse
  belongs_to :wine
  belongs_to :category

  validates :vendor_sku, uniqueness_without_deleted: {
                           scope: :warehouse,
                           case_sensitive: false,
                           message: 'has to be unique per warehouse.'
                       }
end
