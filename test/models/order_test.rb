require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test 'Can calculate order total Price' do
    order = orders(:order1)

    order.order_items.each do |item|
      item.price = 10
    end

    assert(order.total_price == (order.order_items.map { |item| item.price }).inject(:+),
           'Order total price calculation not correct')
  end

  test 'Won\'t calculate order if prices are not set' do
    order = orders(:order1)

    assert(order.total_price.nil?,
           'Order total price should not be calculated if not all prices on order items are set')
  end

  test 'Won\'t calculate order if not all prices are not set' do
    order = orders(:order1)

    order.order_items[0].price = 10

    assert(order.total_price.nil?,
           'Order total price should not be calculated if just some prices are set')
    assert((order.order_items.map { |item| item.price }).include?(nil))
  end

  test 'Can calculate order total Cost' do
    order = orders(:order1)

    order.order_items.each do |item|
      item.cost = 10
    end

    assert(order.total_cost == (order.order_items.map { |item| item.cost }).inject(:+),
           'Order total cost calculation not correct')
  end

  test 'Won\'t calculate order if costs are not set' do
    order = orders(:order1)

    assert(order.total_cost.nil?,
           'Order total price should not be calculated if not all prices on order items are set')
  end

  test 'Won\'t calculate order if not all costs are not set' do
    order = orders(:order1)

    order.order_items[0].cost = 10

    assert(order.total_cost.nil?,
           'Order total price should not be calculated if just some prices are set')
    assert((order.order_items.map { |item| item.cost }).include?(nil))
  end

  test 'Can group by warehouses' do

    device_1 = devices(:one)
    device_2 = devices(:two)
    device_3 = devices(:three)
    device_4 = devices(:four)
    warehouse_1 = warehouses(:one)
    warehouse_1.devices << [device_1, device_2]
    warehouse_2 = warehouses(:two)
    warehouse_2.devices << [device_3, device_4]
    order_1 = orders(:order1)
    order_1.warehouse = warehouse_1
    order_1.status = statuses(:one)
    order_2 = orders(:order2)
    order_2.warehouse = warehouse_2
    order_2.status = statuses(:one)
    order_3 = orders(:order3)
    order_3.warehouse = warehouse_1
    order_3.status = statuses(:one)

    order_1.save
    order_2.save
    order_3.save

    pending_orders = Order.where(:status => Status.statuses[:pending])

    assert(pending_orders.count == 3)

    # You have x number of order(s) pending.

    puts json: pending_orders[0].warehouse.devices.map { |device| device.registration_id }
    puts json: pending_orders[1].warehouse.devices.map { |device| device.registration_id }
    puts json: pending_orders[2].warehouse.devices.map { |device| device.registration_id }

    puts json: pending_orders.map { |order| order.warehouse_id }.count

    notifications = []

    pending_orders.each do |order|

      notification = notifications.select { |notification| notification[:warehouse] == order.warehouse_id }.first
      if notification.blank?
        notifications << {warehouse: order.warehouse_id, order_count: 1, registration_ids: order.warehouse.devices.map { |device| device.registration_id }}
      else
        notification[:order_count] += 1
      end

    end

    puts notifications

  end

  test 'Will return actionable order counts' do
    order_1 = orders(:order1)
    order_2 = orders(:order2)
    order_3 = orders(:order3)

    order_1.status_id = Status.statuses[:pending]
    order_2.status_id = Status.statuses[:packing]
    order_3.status_id = Status.statuses[:pending]

    warehouse_1 = warehouses(:one)
    warehouse_2 = warehouses(:two)

    order_1.warehouse = warehouse_1
    order_2.warehouse = warehouse_1
    order_3.warehouse = warehouse_2

    order_1.save
    order_2.save
    order_3.save

    actionable_order_counts = Order.actionable_order_counts([warehouse_1, warehouse_2], false)

    assert(actionable_order_counts[:pending] == 2, 'Expected 2 pending orders')
    assert(actionable_order_counts[:packing] == 1, 'Expected 1 order in packing status')

  end

  test 'Total price will be zero for orders with free promotion' do
    free_order = orders(:free_bottle_advised)
    assert_equal(0.0, free_order.total_price.to_f)
  end

end
