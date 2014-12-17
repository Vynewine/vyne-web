require 'json'
require 'selenium-webdriver'
require 'test_helper'

class OrderStatusTest < ActiveSupport::TestCase
  test 'Can equeue job' do
    Resque.enqueue(OrderStatus, 1)
  end
end