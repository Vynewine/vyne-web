require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test 'Can calculate order total Price' do
    order = orders(:order1)

    order.order_items.each do |item|
      item.price = 10
    end

    assert(order.total_price == (order.order_items.map { |item| item.price}).inject(:+),
           'Order total price calculation not correct')
  end

  test 'Won\'t calculate order if prices are not set'  do
    order = orders(:order1)

    assert(order.total_price.nil?,
           'Order total price should not be calculated if not all prices on order items are set')
  end

  test 'Won\'t calculate order if not all prices are not set'  do
    order = orders(:order1)

    order.order_items[0].price = 10

    assert(order.total_price.nil?,
           'Order total price should not be calculated if just some prices are set')
    assert((order.order_items.map { |item| item.price}).include?(nil))
  end

  test 'Can calculate order total Cost' do
    order = orders(:order1)

    order.order_items.each do |item|
      item.cost = 10
    end

    assert(order.total_cost == (order.order_items.map { |item| item.cost}).inject(:+),
           'Order total cost calculation not correct')
  end

  test 'Won\'t calculate order if costs are not set'  do
    order = orders(:order1)

    assert(order.total_cost.nil?,
           'Order total price should not be calculated if not all prices on order items are set')
  end

  test 'Won\'t calculate order if not all costs are not set'  do
    order = orders(:order1)

    order.order_items[0].cost = 10

    assert(order.total_cost.nil?,
           'Order total price should not be calculated if just some prices are set')
    assert((order.order_items.map { |item| item.cost}).include?(nil))
  end

end
