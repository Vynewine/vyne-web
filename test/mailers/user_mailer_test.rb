require 'minitest/autorun'


class UserMailerTest < Minitest::Test
  include UserMailer

  def setup
    # Excon.defaults[:mock] = true
    # Excon.stub({}, {body: '{}', status: 200}) # stubs any request to return an empty JSON string
  end

  #Integration Tests
  def test_first_time_ordered_email
    newUser = User.create(first_name: 'Jakub', last_name:'Borys', email: 'jakub.borys@gmail.com')
    results = first_time_ordered newUser
    assert_equal(true, results.kind_of?(Array), 'Bad response from the Mandrill')
    assert_equal('sent', results[0]['status'], msg = "Can't send first_time_ordered email")
  end
end