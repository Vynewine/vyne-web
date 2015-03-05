class WarehousePromotion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :warehouse
  belongs_to :promotion

end