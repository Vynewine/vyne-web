require 'test_helper'
require 'sunspot/rails'
require 'stripe_mock'
require 'mocha/test_unit'
require 'user_mailer'

class ShopControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include UserMailer

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    StripeMock.start
    # Disable mailer
    Excon.defaults[:mock] = true
    Excon.stub({}, {body: '{"dupa":"dupa"}', status: 200}) # stubs any request to return an empty JSON string


    @userOne = User.create!({
                                :first_name => 'John',
                                :last_name => 'Doe',
                                :email => 'john@doe.vn',
                                :mobile => '0999999',
                                :password => 'password',
                                :password_confirmation => 'password'
                            })

    sign_in(:user, @userOne)

    @address = Address.create!({
                                   :line_1 => 'Pickfords Whard',
                                   :line_2 => 'Wharf Road',
                                   :postcode => 'N1 7RJ'
                               })


    AddressesUsers.create!({
                               :user => @userOne,
                               :address => @address
                           })

    @request_data = {
        :address_id => @address.id,
        :stripeToken => 'tok_14m18t2eZvKYlo2CHKjAcAVY',
        :new_brand => '1',
        :new_card => '1111',
        :warehouse_id => warehouses(:one),
        :wines => nil
    }

  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
    StripeMock.stop
  end

  test 'Will create order for food matching' do

    wines = [
        {
            :quantity => 1,
            :food => [
                {:id => 10, :preparation => preparations(:grill_BBQ).id},
                {:id => 13, :preparation => preparations(:roasted).id},
                {:id => 33}
            ],
            :category => categories(:house).id

        },
        {
            :quantity => 1,
            :food => [{:id => 10}, {:id => 13}, {:id => 33}],
            :category => categories(:reserve).id
        }
    ]

    @request_data[:wines] = wines.to_json

    post :create, @request_data

    payment = Payment.find_by user: @userOne
    order = Order.find_by client: @userOne

    puts @response.body

    assert_equal(order.payment, payment)
    assert_equal(order.client, @userOne)
    assert_equal(payment.user, @userOne)

    assert_equal({"warehouse_id" => warehouses(:one).id.to_s}, order.information)
    assert_equal(2, order.order_items.count, 'There should be 2 order items')
    categories = order.order_items.map { |c| c.category.id }
    assert_equal(true, (categories.include? categories(:house).id) && (categories.include? categories(:reserve).id), 'House and Reserve wines should be present on the order.')
    assert(!order.address.nil?, 'Order should have address assigned')
  end

  test 'Will create order for occasion matching' do

    wines = [
        {
            :quantity => 2,
            :occasion => occasions(:one).id,
            :wineType => {:id => types(:one).id},
            :category => categories(:house).id
        }
    ]

    @request_data[:wines] = wines.to_json

    post :create, @request_data

    order = Order.find_by client: @userOne

    assert_equal(occasions(:one), order.order_items[0].occasion)
    assert_equal(types(:one), order.order_items[0].type)

  end

  test 'Will create order for specific wine' do

    wines = [
        {
            :quantity => 1,
            :specificWine => 'Chateauneuf-du-Pape',
            :category => categories(:house).id
        }
    ]

    @request_data[:wines] = wines.to_json

    post :create, @request_data

    order = Order.find_by client: @userOne

    assert_equal('Chateauneuf-du-Pape', order.order_items[0].specific_wine)
  end

  test 'Will handle stripe errors' do
    StripeMock.stop
    stripe_key = Rails.application.config.stripe_key
    Rails.application.config.stripe_key = nil

    post :create, post_data

    assert_equal('Error occurred while creating customer with Stripe', JSON.parse(response.body)[0])

    #Reset Stripe Key for all other tests.
    Rails.application.config.stripe_key = stripe_key
    StripeMock.start
  end

  test 'Will assign closest warehouse to the order' do
    order = orders(:order1)

    warehouse_one = warehouses(:one)
    warehouse_two = warehouses(:two)


    warehouses = '{"warehouses":[{"id":' + warehouse_one.id.to_s + ',"distance":2.369,"is_open":true},
    {"id":' + warehouse_two.id.to_s + ',"distance":1.369,"is_open":true}]}'

    order.warehouse = @controller.send(:assign_warehouse, warehouses)
    order.save
    saved_order = Order.find(order)
    assert_equal(warehouse_two, saved_order.warehouse)
  end

  test 'Will create order for booked slot' do
    time_now = Time.parse('1996/01/01 00:00') #Monday
    Time.stubs(:now).returns(time_now)
    post :create, post_data_new
    order = Order.find_by client: @userOne
    assert_equal(Status.statuses[:created], order.status_id)

  end

  test 'Will create order with promotion for new user' do

    user = users(:client)

    sign_in(:user, user)

    post :create, post_data_single_house

    order_details =  JSON.parse @response.body

    puts JSON.pretty_generate(order_details)

    order = Order.find(order_details['id'])

    assert_equal(2, order.order_items.count)
    assert_equal(1, order.order_items.select{|item| item.user_promotion == user.user_promotions.first}.count)
    assert(1, user.user_promotions.select{|promotion| promotion.can_be_redeemed}.count)
    assert(1, user.user_promotions.select{|promotion| promotion.redeemed}.count)
    assert_equal(2.5, order.delivery_price)
  end

  def post_data
    {
        'email' => '',
        'warehouse_id' => warehouses(:one),
        'wines' => '[
      {
        "quantity":1, "category":"' + categories(:house).id.to_s + '",
        "label":"House", "price":"£15", "specificWine":"",
        "food":[{"id":"14","name":"fish"}, {"id":"35", "name":"herbs"}, {"id":"10", "name":"cured meat"} ],"occasion":[]
      },
      {
        "quantity":1, "category":"' + categories(:reserve).id.to_s + '",
        "label":"Reserve","price":"£20", "specificWine":"",
        "food":[{"id":"14", "name":"fish"}, {"id":"18","name":"hard cheese"},{"id":"38","name":"pasta"}], "occasion":[]
      }]',
        'address_s' => '',
        'address_d' => '',
        'address_id' => addresses(:one).id,
        'old_card' => '0',
        'new_card' => '1111',
        'new_brand' => '1',
        'stripeToken' => 'tok_14tFx92eZvKYlo2CxthO99kb'
    }
  end

  def post_data_new

    {
        'warehouse_id' => warehouses(:two).id.to_s,
        'slot_date' => Time.now.strftime('%F'),
        'slot_from' => '14:00',
        'slot_to' => '15:00',
        'wines' => '[
      {
        "quantity":1, "category":"' + categories(:house).id.to_s + '",
        "label":"House", "price":"£15", "specificWine":"",
        "food":[{"id":"14","name":"fish"}, {"id":"35", "name":"herbs"}, {"id":"10", "name":"cured meat"} ],"occasion":[]
      },
      {
        "quantity":1, "category":"' + categories(:reserve).id.to_s + '",
        "label":"Reserve","price":"£20", "specificWine":"",
        "food":[{"id":"14", "name":"fish"}, {"id":"18","name":"hard cheese"},{"id":"38","name":"pasta"}], "occasion":[]
      }]',
        'address_id' => addresses(:one).id,
        'old_card' => '0',
        'new_card' => '1111',
        'new_brand' => '1',
        'stripeToken' => 'tok_14tFx92eZvKYlo2CxthO99kb'
    }
  end

  def post_data_single_house
    {
        'email' => '',
        'warehouse_id' => warehouses(:one),
        'wines' => '[
      {
        "quantity":1, "category":"' + categories(:house).id.to_s + '",
        "label":"House", "price":"£15", "specificWine":"",
        "food":[{"id":"14","name":"fish"}, {"id":"35", "name":"herbs"}, {"id":"10", "name":"cured meat"} ],"occasion":[]
      }
      ]',
        'address_s' => '',
        'address_d' => '',
        'address_id' => addresses(:one).id,
        'old_card' => '0',
        'new_card' => '1111',
        'new_brand' => '1',
        'stripeToken' => 'tok_14tFx92eZvKYlo2CxthO99kb'
    }
  end

end