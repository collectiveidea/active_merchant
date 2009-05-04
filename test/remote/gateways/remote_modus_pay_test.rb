require File.dirname(__FILE__) + '/../../test_helper'

class RemoteModusPayTest < Test::Unit::TestCase
  

  def setup
    @gateway = ModusPayGateway.new(fixtures(:modus_pay))
    
    @amount = 100
    # @credit_card = credit_card('4000100011112224')
    # @declined_card = credit_card('4000300011112220')
    @check = check
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :shipping_address => address,
      :email => 'sam@example.com',
      :drivers_license_state => 'CA',
      :drivers_license_number => '12345689',
      :date_of_birth => Date.new(1978, 8, 11),
      :ssn => '078051120'
    }
  end
  
  def test_successful_check_purchase
    assert response = @gateway.purchase(@amount, @check, @options)
    # assert_success response
    # assert response.test?
    # assert_false response.authorization.blank?
  end
  
  # def test_unsuccessful_purchase
  #   assert response = @gateway.purchase(@amount, @declined_card, @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
  # end
  # 
  
  def test_successful_login
    response = @gateway.send(:login)
    assert_not_nil response.root.get_elements('//LoginResult')[0]
  end
  
  def test_successful_login_sets_ticket
    assert_nil @gateway.ticket
    @gateway.send(:login)
    assert_not_nil @gateway.ticket    
  end
  
  def test_unsuccessful_login
    gateway = ModusPayGateway.new(
                :login => '',
                :password => ''
              )
    response = gateway.send(:login)
    assert_nil response.root.get_elements('//LoginResult')[0]
  end
  
  def test_successful_logoff
    @gateway.send(:login)
    
    response = @gateway.send(:logoff)
    assert_match /LogoffResponse/, response
  end
end
