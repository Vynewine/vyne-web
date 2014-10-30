require 'test_helper'
require 'sunspot/rails'
require 'stripe_mock'


class ShopControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    StripeMock.start
    # Disable mailer
    Excon.defaults[:mock] = true
    Excon.stub({}, {body: '{}', status: 200}) # stubs any request to return an empty JSON string

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
                                   :detail => '8A',
                                   :street => 'Pickfords Whard',
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
        :warehouses => '{"warehouses":[{"id":' + warehouses(:one).id.to_s + ',"distance":1.914},{"id":' + warehouses(:two).id.to_s + ',"distance":2.123}]}',#{ :warehouses => [{ :id => 1, :distance => 2.5 }, { :id => 2, :distance => 1.8}],
        :wines => nil
    }

  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
    StripeMock.stop
  end

  test 'should create order for food matching' do

    wines = [
            {
                 :quantity => 1,
                 :food => [{:id => 10},{:id => 20},{:id => 33}],
                 :category => categories(:house).id

            },
             {
                 :quantity => 1,
                 :food => [{:id => 10},{:id => 20},{:id => 33}],
                 :category => categories(:reserve).id
             }
    ]

    @request_data[:wines] = wines.to_json

    post :create, @request_data

    payment = Payment.find_by user: @userOne
    order = Order.find_by client: @userOne

    assert_redirected_to order
    assert_response(:redirect, message = nil)
    assert_equal(order.payment, payment)
    assert_equal(order.client, @userOne)
    assert_equal(payment.user, @userOne)
    expected_information= { "warehouses" => [{ "id" => warehouses(:one).id, "distance" => 1.914 }, { "id" => warehouses(:two).id, "distance" => 2.123}]}
    assert_equal(expected_information, order.information)
    assert_equal(2, order.order_items.count, 'There should be 2 order items')
    categories = order.order_items.map { |c| c.category.id}
    assert_equal(true, (categories.include? categories(:house).id) && (categories.include? categories(:reserve).id), 'House and Reserve wines should be present on the order.')
    assert(!order.address.nil?, 'Order should have address assigned')
  end

  test 'should create order for occasion matching' do

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

    assert_redirected_to order
    assert_equal(occasions(:one), order.order_items[0].occasion)
    assert_equal(types(:one), order.order_items[0].type)

  end

  test 'should create order for specific wine' do

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
    assert_redirected_to order
    assert_equal('Chateauneuf-du-Pape', order.order_items[0].specific_wine)
  end

  test 'will get discount on second bottle' do
    wines = [
        {
            :quantity => 1,
            :food => [{:id => 10},{:id => 20},{:id => 33}],
            :category => categories(:house).id

        },
        {
            :quantity => 1,
            :food => [{:id => 10},{:id => 20},{:id => 33}],
            :category => categories(:house).id
        }
    ]

    @request_data[:wines] = wines.to_json

    post :create, @request_data

    order = Order.find_by client: @userOne

    assert(order.order_items.count == 2, 'Order should have 2 order items')
    assert_equal(25, order.total_price.to_i, 'Order total price should be 25')

  end

  test 'ui post' do

    post :create, post_data

    order = Order.find_by client: @userOne

    puts json: order.order_items

    order.order_items.each { |item| puts json: item.foods }

  end

  def post_data
    {"utf8"=>"✓",
     "authenticity_token"=>"q9C5QhmjyfeFd1LbXlSgvc10kAiswGKksYTluQCYTf0=",
     "email"=>"",
     "warehouses"=>"{\"warehouses\":[{\"id\":1,
\"distance\":1.914}]}",
     "category"=>categories(:house),
     "specific-wine"=>"",
     "wines"=>"[{\"quantity\":1,
\"category\":" + categories(:house).id.to_s + ",
\"label\":\"House\",
\"price\":\"£15\",
\"specificWine\":\"\",
\"food\":[{\"id\":\"14\",
\"name\":\"fish\"},
{\"id\":\"35\",
\"name\":\"herbs\"},
{\"id\":\"10\",
\"name\":\"cured meat\"}],
\"occasion\":[]},
{\"quantity\":1,
\"category\":" + categories(:reserve).id.to_s + ",
\"label\":\"Reserve\",
\"price\":\"£20\",
\"specificWine\":\"\",
\"food\":[{\"id\":\"14\",
\"name\":\"fish\"},
{\"id\":\"18\",
\"name\":\"hard cheese\"},
{\"id\":\"38\",
\"name\":\"pasta\"}],
\"occasion\":[]}]",
     "address_s"=>"8a Pickfords Wharf,
 Wharf Road",
     "address_d"=>"",
     "address_id"=> addresses(:one).id,
     "old_card"=>"0",
     "new_card"=>"1111",
     "new_brand"=>"1",
     "stripeToken"=>"tok_14tFx92eZvKYlo2CxthO99kb"}
  end

end