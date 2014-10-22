require 'test_helper'

class OrderItemTest < ActiveSupport::TestCase
  setup do
    @order = orders(:order1)
    @wine = wines(:one)
    @food_selection_one = Food.new({name: 'beef'})
    @food_selection_two = Food.new({name: 'grill & BBQ'})
  end

  test 'should create order' do

    total_order_items = 1 + rand(2)
    @order_items = Array.new

    total_order_items.times do
      @order_items << OrderItem.create({quantity: 1, wine: @wine, foods: [@food_selection_one, @food_selection_two]})
    end

    @order.order_items = @order_items
    assert(@order_items.length == total_order_items, 'Wrong number of Order Items')
    for item in @order_items
      assert(item.foods.length == 2, 'Two food selections should belong to each order item')
    end
  end
end