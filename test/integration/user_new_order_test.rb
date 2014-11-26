require 'json'
require 'selenium-webdriver'
require 'test_helper'

class UserNewOrderTest < ActiveSupport::TestCase

  def setup
    WebMock.allow_net_connect!
    @driver = Selenium::WebDriver.for :firefox
    @base_url = 'http://localhost:3000/'
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 10
    @verification_errors = []
    @wait = Selenium::WebDriver::Wait.new(:timeout => 2)
  end

  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end

  test 'New user one bottle' do

    email = Time.now.strftime('%Y%m%d%H%M%S') + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/')

    enter_promo_code
    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    confirm_order_selection
    register_new_user(email, password)
    register_new_address
    register_new_credit_card
    submit_order

    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Thanks for ordering')]").displayed? }
  end

  test 'Existing user one bottle' do

    email = Time.now.strftime('%Y%m%d%H%M%S') + '@vyne.london'
    password = 'password'

    @driver.get(@base_url + '/')

    enter_promo_code
    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    confirm_order_selection
    register_new_user(email, password)
    register_new_address
    register_new_credit_card
    submit_order

    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Thanks for ordering')]").displayed? }

    @driver.find_element(:css, 'a.menu-link').click
    @wait.until { @driver.find_element(:css, 'a.sign-out').displayed? }
    @driver.find_element(:css, 'a.sign-out').click

    enter_postcode_first_page('n17rj')
    select_bottle_for_category(2)
    select_wine_by_occasion
    confirm_order_selection
    login_existing_user(email, password)
    confirm_existing_address
    submit_order
    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Thanks for ordering')]").displayed? }

  end

  test 'Sign in and out' do
    @driver.get(@base_url + '/login')
    @driver.find_element(:id, 'user_email').clear
    @driver.find_element(:id, 'user_email').send_keys 'jakub.borys@gmail.com'
    @driver.find_element(:id, 'user_password').clear
    @driver.find_element(:id, 'user_password').send_keys 'Wines1234'
    @driver.find_element(:name, 'commit').click
    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Matching great wines')]").displayed? }
    @driver.find_element(:css, 'a.menu-link').click
    @wait.until { @driver.find_element(:css, 'a.sign-out').displayed? }
    @driver.find_element(:css, 'a.sign-out').click
    @wait.until { @driver.find_element(:xpath, "//*[contains(text(), 'Matching great wines')]").displayed? }
  end


  def enter_promo_code
    unless Rails.application.config.enable_invite_code == 'false'
      puts 'Entering Promo Code'
      @driver.find_element(:id, 'invite-code').clear
      @driver.find_element(:id, 'invite-code').send_keys 'timeforvyne'
      @driver.find_element(:id, 'submit-invite-code').click
    end
  end

  def enter_postcode_first_page(postcode)
    puts 'Entering postcode' + postcode
    @driver.find_element(:id, 'filterPostcode').clear
    @driver.find_element(:id, 'filterPostcode').send_keys postcode
    @driver.find_element(:css, 'input[type=\'submit\']').click
    @driver.find_element(:id, 'use-postcode').click
  end

  def select_bottle_for_category(category)
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

  def confirm_order_selection
    puts 'Confirming order selection'
    @wait.until { @driver.find_element(:css, '#review-panel').displayed? }
    @wait.until { @driver.find_element(:id, 'checkout').displayed? }
    @driver.find_element(:id, 'checkout').click
  end

  def register_new_user(email, password)
    puts 'Registering new user'
    @driver.find_element(:id, 'user_first_name').clear
    @driver.find_element(:id, 'user_first_name').send_keys 'Jakub'
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
    @driver.find_element(:id, 'mobile').send_keys '+44 7718225201'
    @driver.find_element(:id, 'address-details').click
  end

  def confirm_existing_address
    puts 'Confirming existing address'
    @wait.until { @driver.find_element(:css, '#delivery-panel').displayed? }
    @wait.until { @driver.find_element(:id, 'address-details').displayed? }
    @driver.find_element(:id, 'address-details').click
  end

  def register_new_credit_card
    puts 'Registering new card'
    @driver.find_element(:id, 'pmnm').clear
    @driver.find_element(:id, 'pmnm').send_keys '4111111111111111'
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
