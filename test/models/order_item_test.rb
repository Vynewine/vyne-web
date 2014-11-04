require 'test_helper'

class OrderItemTest < ActiveSupport::TestCase
  setup do
    @order = orders(:order1)
    @wine = wines(:one)
    @food = Food.new({name: 'beef'})
    @preparation = Preparation.new({name:'grill & BBQ'})
    @food2 = Food.new({name: 'chicken'})
    @preparation2 = Preparation.new({name:'fried & sautéed'})
  end

  test 'should create order' do

    @order_items = Array.new

    2.times do
      new_item = OrderItem.create({quantity: 1, wine: @wine})
      FoodItem.create!(:food => @food, :preparation => @preparation, :order_item => new_item)
      FoodItem.create!(:food => @food2, :preparation => @preparation2, :order_item => new_item)
      @order_items << new_item
    end

    @order.order_items = @order_items
    assert(@order_items.length == 2, 'Wrong number of Order Items')
    for item in @order_items
      assert(item.food_items.count == 2, 'There should be one FoodItem')
      assert_equal(@preparation, item.food_items[0].preparation, 'Preparation don\'t match')
      assert_equal(@food, item.food_items[0].food, 'Preparation don\'t match')
    end
  end
end