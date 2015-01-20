class Category < ActiveRecord::Base
  acts_as_paranoid

  def name_with_ranges
    "#{name} (£#{'%.2f' % merchant_price_min}-#{'%.2f' % merchant_price_max})"
  end
end
