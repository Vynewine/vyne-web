require 'json'
require 'selenium-webdriver'
require 'test_helper'

class UserNewOrderTest < ActiveSupport::TestCase

  def setup
    WebMock.allow_net_connect!
    @driver = Selenium::WebDriver.for :firefox
    @base_url = 'http://localhost:5000/'
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 10
    @verification_errors = []
    @wait = Selenium::WebDriver::Wait.new(:timeout => 5)
  end

  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end

  test 'New user one bottle' do

    email = Time.now.strftime('%Y%m%d%H%M%S') + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/')

    enter_postcode_first_page('n17rj', true)
    select_bottle_for_category(2)
    select_wine_by_occasion
    confirm_order_selection
    register_new_user(email, password)
    register_new_address
    register_new_credit_card
    submit_order

    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Thank you for ordering')]").displayed? }
  end

  test 'Will show credit card error' do

    email = Time.now.strftime('%Y%m%d%H%M%S') + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/')

    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    confirm_order_selection
    register_new_user(email, password)
    register_new_address
    register_new_credit_card('4000000000000002')
    submit_order

    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'declined')]").displayed? }

    @driver.find_element(:id, 'pmnm').clear
    @driver.find_element(:id, 'pmnm').clear
    @driver.find_element(:id, 'pmnm').send_keys '4111111111111111'

    submit_order

    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Thank you for ordering')]").displayed? }
  end

  test 'New user two different bottles' do

    email = Time.now.strftime('%Y%m%d%H%M%S') + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/')

    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    select_second_bottle
    select_bottle_for_category(2)
    select_wine_by_food
    confirm_order_selection
    register_new_user(email, password)
    register_new_address
    register_new_credit_card
    submit_order

    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Thank you for ordering')]").displayed? }
  end

  test 'New user two of the same bottles' do

    email = Time.now.strftime('%Y%m%d%H%M%S') + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/')

    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    add_same_bottle
    confirm_order_selection
    register_new_user(email, password)
    register_new_address
    register_new_credit_card
    submit_order

    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Thank you for ordering')]").displayed? }

    assert_xpath('Reserve (£15.00-20.00)', '//*[@id="order-details"]/div/div[2]/div[1]/div[2]/div[2]/div/span[3]')
    assert_xpath('Reserve (£15.00-20.00)', '//*[@id="order-details"]/div/div[2]/div[1]/div[2]/div[5]/div/span[3]')
    assert_xpath('32.50 - 42.50', '//*[@id="order-details"]/div/div[2]/div[1]/div[3]/div/div[2]/span[2]')
    assert_xpath('2.50', '//*[@id="order-details"]/div/div[2]/div[1]/div[3]/div/div[1]/span[2]')

  end

  test 'Existing user one bottle' do

    email = Time.now.strftime('%Y%m%d%H%M%S') + '@vyne.london'
    password = 'password'
    first_name = 'Mike'

    @driver.get(@base_url + '/')

    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    confirm_order_selection
    register_new_user(email, password, first_name)
    register_new_address
    register_new_credit_card
    submit_order

    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Thank you for ordering')]").displayed? }

    @driver.find_element(:id, 'user_navigation').click
    @driver.find_element(:id, 'logout').click

    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    confirm_order_selection
    login_existing_user(email, password)
    confirm_existing_address
    submit_order
    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Thank you for ordering')]").displayed? }

  end

  test 'Sign in and out' do
    @driver.get(@base_url + '/login')
    @driver.find_element(:id, 'user_email').clear
    @driver.find_element(:id, 'user_email').send_keys 'jakub.borys@gmail.com'
    @driver.find_element(:id, 'user_password').clear
    @driver.find_element(:id, 'user_password').send_keys 'Wines1234'
    @driver.find_element(:name, 'commit').click
    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Wine delivered from London’s top cellars')]").displayed? }
    @driver.find_element(:id, 'user_navigation').click
    @driver.find_element(:id, 'logout').click
    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Wine delivered from London’s top cellars')]").displayed? }
  end

  test 'New user two bottles with extra bottle promotion' do

    promo_code = 'VYNEHEROES'
    name = rand(36**5).to_s(36).capitalize
    email = name + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/promo')

    enter_promo_code(promo_code, 'n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    select_second_bottle
    select_bottle_for_category(2)
    select_wine_by_food
    confirm_order_selection
    register_new_user(email, password, name)
    register_new_address
    register_new_credit_card
    submit_order

    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Promotion')]").displayed? }
    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), '2.50')]").displayed? }
  end

  test 'New user free promotion' do
    promo_code = 'VIP-WINE'
    name = rand(36**5).to_s(36).capitalize
    email = name + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/promo')

    enter_promo_code(promo_code, 'n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    confirm_order_selection
    register_new_user(email, password, name)
    register_new_address
    submit_order
    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Promotion')]").displayed? }
  end

  test 'New account with new account promotion' do
    name = Time.now.strftime('%Y%m%d%H%M%S')
    email = name + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/promo')

    enter_promo_code('VYNEHEROES', 'n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    confirm_order_selection
    register_new_user(email, password, name)

  end

  test 'Register User' do
    name = Time.now.strftime('%Y%m%d%H%M%S')
    email = name + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/users/sign_up')

    @driver.find_element(:id, 'user_first_name').send_keys name
    @driver.find_element(:id, 'user_last_name').send_keys 'Borys'
    @driver.find_element(:id, 'user_email').send_keys email
    @driver.find_element(:id, 'user_mobile').send_keys '07718225201'
    @driver.find_element(:id, 'user_password').send_keys password
    @driver.find_element(:id, 'user_password_confirmation').send_keys password

    @driver.find_element(:css, 'input[type=\'submit\']').click
    @wait.until { @driver.find_element(:xpath, "//*[@id=\"document\"]//*[contains(text(), '#{email}')]").displayed? }

  end

  test 'Page contains text' do
    email = 'jakub.borys@gmail.com'
    @driver.get(@base_url + '/login')
    @driver.find_element(:id, 'user_email').send_keys email
    @driver.find_element(:id, 'user_password').send_keys 'Wines1234'
    @driver.find_element(:css, 'input[type=\'submit\']').click
    @driver.get(@base_url + '/account')
    @wait.until { @driver.find_element(:xpath, "//*[@id=\"document\"]//*[contains(text(), '#{email}')]").displayed? }
  end

  test 'Manipulate shopping cart' do

    @driver.get(@base_url + '/')

    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion

    assert_xpath('Reserve', '//*[@id="cart"]/div/table/tbody/tr[1]/td[1]/div[2]/span')
    assert_xpath('Party', '//*[@id="cart"]/div/table/tbody/tr[1]/td[1]/div[3]/span')
    assert_xpath('Light Red', '//*[@id="cart"]/div/table/tbody/tr[1]/td[1]/div[5]/span')
    assert_xpath('15', '//*[@id="cart"]/div/table/tbody/tr[1]/td[2]/span/span[2]')
    assert_xpath('20', '//*[@id="cart"]/div/table/tbody/tr[1]/td[2]/span/span[4]')
    assert_xpath('2.50', '//*[@id="cart"]/div/table/tbody/tr[4]/td/div[1]/span[4]')
    assert_xpath('17.50', '//*[@id="cart"]/div/table/tbody/tr[4]/td/div[3]/span[4]/span[1]')
    assert_xpath('22.50', '//*[@id="cart"]/div/table/tbody/tr[4]/td/div[3]/span[4]/span[3]')

    add_same_bottle

    assert_xpath('Reserve', '//*[@id="cart"]/div/table/tbody/tr[2]/td[1]/div[2]/span')
    assert_xpath('Party', '//*[@id="cart"]/div/table/tbody/tr[2]/td[1]/div[3]/span')
    assert_xpath('Light Red', '//*[@id="cart"]/div/table/tbody/tr[2]/td[1]/div[5]/span')
    assert_xpath('15', '//*[@id="cart"]/div/table/tbody/tr[2]/td[2]/span/span[2]')
    assert_xpath('20', '//*[@id="cart"]/div/table/tbody/tr[2]/td[2]/span/span[4]')
    assert_xpath('2.50', '//*[@id="cart"]/div/table/tbody/tr[5]/td/div[1]/span[4]')
    assert_xpath('32.50', '//*[@id="cart"]/div/table/tbody/tr[5]/td/div[3]/span[4]/span[1]')
    assert_xpath('42.50', '//*[@id="cart"]/div/table/tbody/tr[5]/td/div[3]/span[4]/span[3]')

    remove_second_bottle
    select_second_bottle
    select_bottle_for_category(1)
    select_wine_by_food

    assert_xpath('House', '//*[@id="cart"]/div/table/tbody/tr[2]/td[1]/div[2]/span')
    assert_xpath('beef (grill & BBQ)', '//*[@id="cart"]/div/table/tbody/tr[2]/td[1]/ul/li[1]')
    assert_xpath('green vegetables (roasted)', '//*[@id="cart"]/div/table/tbody/tr[2]/td[1]/ul/li[2]')
    assert_xpath('pasta', '//*[@id="cart"]/div/table/tbody/tr[2]/td[1]/ul/li[3]')
    assert_xpath('10', '//*[@id="cart"]/div/table/tbody/tr[2]/td[2]/span/span[2]')
    assert_xpath('15', '//*[@id="cart"]/div/table/tbody/tr[2]/td[2]/span/span[4]')
    assert_xpath('27.50', '//*[@id="cart"]/div/table/tbody/tr[5]/td/div[3]/span[4]/span[1]')
    assert_xpath('37.50', '//*[@id="cart"]/div/table/tbody/tr[5]/td/div[3]/span[4]/span[3]')

    remove_first_bottle

    assert_xpath('3.50', '//*[@id="cart"]/div/table/tbody/tr[4]/td/div[1]/span[4]')
    assert_xpath('13.50', '//*[@id="cart"]/div/table/tbody/tr[4]/td/div[3]/span[4]/span[1]')
    assert_xpath('18.50', '//*[@id="cart"]/div/table/tbody/tr[4]/td/div[3]/span[4]/span[3]')

  end

  test 'Choose specific wine' do
    @driver.get(@base_url + '/')

    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_specific_wine('Chateau Margaux')
    assert_xpath('Reserve', '//*[@id="cart"]/div/table/tbody/tr[1]/td[1]/div[2]/span')
    assert_xpath('Chateau Margaux', '//*[@id="cart"]/div/table/tbody/tr[1]/td[1]/div[4]/span')

  end

  def assert_xpath(expected_value, xpath)
    assert_equal(expected_value, @driver.find_element(:xpath, xpath).text)
  end

  def enter_promo_code(promo_code, postcode)

    puts 'Entering Promo Code'
    @driver.find_element(:name, 'promo_code').send_keys promo_code
    @driver.find_element(:name, 'postcode').send_keys postcode
    @driver.find_element(:css, 'input[type=\'submit\']').click
    @driver.find_element(:xpath, "//button[contains(text(),'Now')]").click

  end

  def enter_postcode_first_page(postcode, booked_slot = false)
    puts 'Entering postcode' + postcode
    @driver.find_element(:id, 'filterPostcode').clear
    @driver.find_element(:id, 'filterPostcode').send_keys postcode
    @driver.find_element(:css, 'input[type=\'submit\']').click
    if booked_slot
      @driver.find_element(:xpath, "//button[contains(text(),'Book Now')]").click
    else
      @driver.find_element(:xpath, "//button[contains(text(),'Now')]").click || @driver.find_element(:xpath, "//button[contains(text(),'Book Now')]").click
    end
  end

  def select_bottle_for_category(category)
    puts 'Selecting bootle by category' + category.to_s
    @wait.until { @driver.find_element(:css, '#bottles-panel').displayed? }
    @wait.until { @driver.find_element(:xpath, "//div[@id='bottles-panel']/div/ul/li[" + category.to_s + "]/a").displayed? }
    @driver.find_element(:xpath, "//div[@id='bottles-panel']/div/ul/li[" + category.to_s + "]/a").click
    @wait.until { @driver.find_element(:css, 'div.bottle-info.active > div.bottle-info-content > a.btn.select-bottle').displayed? }
    @driver.find_element(:css, 'div.bottle-info.active > div.bottle-info-content > a.btn.select-bottle').click
  end

  def select_wine_by_occasion
    puts 'Selecting wine by occasion'
    @wait.until { @driver.find_element(:link, 'By occasion').displayed? }
    @driver.find_element(:link, 'By occasion').click
    @wait.until { @driver.find_element(:css, '#occasion-3 > a > img[alt=\'image description\']') }
    @driver.find_element(:css, '#occasion-3 > a > img[alt=\'image description\']').click
    @driver.find_element(:css, '#winetype-3 > a > img[alt=\'image description\']').click
  end

  def select_second_bottle
    puts 'Selecting second bottle'
    @wait.until { @driver.find_element(:css, '#review-panel').displayed? }
    #@wait.until { @driver.find_element(:link, '#add-another-bottle').displayed? }
    @driver.find_element(:id, 'add-another-bottle').click
  end

  def add_same_bottle
    puts 'Adding the same bottle'
    @wait.until { @driver.find_element(:css, '#review-panel').displayed? }
    #@wait.until { @driver.find_element(:link, '#add-another-bottle').displayed? }
    @driver.find_element(:id, 'add-same-bottle').click
  end

  def remove_first_bottle
    puts 'Removing First Bottle'
    @wait.until { @driver.find_element(:css, '#review-panel').displayed? }
    @driver.find_element(:xpath, '//*[@id="cart"]/div/table/tbody/tr[1]/td[1]/a').click
  end

  def remove_second_bottle
    puts 'Removing Second Bottle'
    @wait.until { @driver.find_element(:css, '#review-panel').displayed? }
    @driver.find_element(:xpath, '//*[@id="cart"]/div/table/tbody/tr[2]/td[1]/a').click
  end

  def select_wine_by_food
    puts 'Selecting wine by food'
    @wait.until { @driver.find_element(:link, 'With food').displayed? }
    @driver.find_element(:link, 'With food').click
    @wait.until { @driver.find_element(:css, '#food-1 > a > span').displayed? }
    @driver.find_element(:css, '#food-1 > a > span').click
    @driver.find_element(:css, '#food-9 > a > span').click
    @driver.find_element(:css, '#preparation-list > #food-1 > a > span').click
    @driver.find_element(:css, '#food-5 > a > img.logo').click
    @driver.find_element(:css, '#food-25 > a > img[alt=\'image description\']').click
    @driver.find_element(:css, '#preparation-list > #food-2 > a > img[alt=\'image description\']').click
    @driver.find_element(:css, '#food-7 > a > img.logo').click
    @driver.find_element(:css, '#food-38 > a > img[alt=\'image description\']').click
    @driver.find_element(:id, 'select-preferences').click

  end

  def select_specific_wine(specific_wine = 'bordeaux')
    putc 'Selecting specific wine'
    @wait.until { @driver.find_element(:id, 'specific-wine').displayed? }
    @driver.find_element(:xpath, '//*[@id="matching-wine"]/div/input').send_keys specific_wine
    @driver.find_element(:id, 'specific-wine').click
  end

  def confirm_order_selection
    puts 'Confirming order selection'
    @wait.until { @driver.find_element(:css, '#review-panel').displayed? }
    @wait.until { @driver.find_element(:id, 'checkout').displayed? }
    @driver.find_element(:id, 'checkout').click
  end

  def register_new_user(email, password, first_name = 'Jakub')
    puts 'Registering new user'
    @driver.find_element(:id, 'user_first_name').clear
    @driver.find_element(:id, 'user_first_name').send_keys first_name
    @driver.find_element(:id, 'user_last_name').clear
    @driver.find_element(:id, 'user_last_name').send_keys 'Borys'
    @driver.find_element(:id, 'user_email').clear
    @driver.find_element(:id, 'user_email').send_keys email
    @driver.find_element(:id, 'user_password').clear
    @driver.find_element(:id, 'user_password').send_keys password
    @driver.find_element(:id, 'delivery-details').click
  end

  def login_existing_user(email, password)
    puts 'Logging in existing user'
    @driver.find_element(:id, 'account-link').click
    @driver.find_element(:id, 'user_email').clear
    @driver.find_element(:id, 'user_email').send_keys email
    @driver.find_element(:id, 'user_password').clear
    @driver.find_element(:id, 'user_password').send_keys password
    @driver.find_element(:id, 'delivery-details').click
  end

  def register_new_address
    puts 'Register new address'
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, 'suggested-addresses')).select_by(:text, '8a Pickfords Wharf, Wharf Road')
    @driver.find_element(:id, 'mobile').clear
    @driver.find_element(:id, 'mobile').send_keys '+447718225201'
    @driver.find_element(:id, 'address-details').click
  end

  def confirm_existing_address
    puts 'Confirming existing address'
    @wait.until { @driver.find_element(:css, '#delivery-panel').displayed? }
    @wait.until { @driver.find_element(:id, 'address-details').displayed? }
    @driver.find_element(:id, 'address-details').click
  end

  def register_new_credit_card(card_number = '4111111111111111')
    puts 'Registering new card'
    @driver.find_element(:id, 'pmnm').clear
    @driver.find_element(:id, 'pmnm').send_keys card_number
    @driver.find_element(:id, 'pmcv').clear
    @driver.find_element(:id, 'pmcv').send_keys '542'
    @driver.find_element(:id, 'pmxp').clear
    @driver.find_element(:id, 'pmxp').send_keys '0717'
  end

  def submit_order
    puts 'Submitting order'
    @driver.find_element(:id, 'submit-order').click
  end
end
