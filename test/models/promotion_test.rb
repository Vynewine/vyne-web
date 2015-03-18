require 'test_helper'

class PromotionTest < ActiveSupport::TestCase
  test 'Can find by category' do
    promotion = Promotion.find_by(category: Promotion.categories[:wine])
    assert_equal('Mystery Bottle', promotion.title)
  end
end