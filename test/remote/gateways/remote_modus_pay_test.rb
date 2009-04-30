require File.dirname(__FILE__) + '/../../test_helper'

class RemoteModusPayTest < Test::Unit::TestCase
  

  def setup
    @gateway = ModusPayGateway.new(fixtures(:modus_pay))
    
    @amount = 100
    @credit_card = credit_card('4000100011112224')
    @declined_card = credit_card('4000300011112220')
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end
  
  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    puts response
    assert_success response
    assert_equal 'REPLACE WITH SUCCESS MESSAGE', response.message
  end

  # def test_unsuccessful_purchase
  #   assert response = @gateway.purchase(@amount, @declined_card, @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
  # end
  # 
  # def test_authorize_and_capture
  #   amount = @amount
  #   assert auth = @gateway.authorize(amount, @credit_card, @options)
  #   assert_success auth
  #   assert_equal 'Success', auth.message
  #   assert auth.authorization
  #   assert capture = @gateway.capture(amount, auth.authorization)
  #   assert_success capture
  # end
  # 
  # def test_failed_capture
  #   assert response = @gateway.capture(@amount, '')
  #   assert_failure response
  #   assert_equal 'REPLACE WITH GATEWAY FAILURE MESSAGE', response.message
  # end
  # 
  
  def test_successful_login
    gateway = ModusPayGateway.new(fixtures(:modus_pay))
    response = gateway.send(:login)
    assert_not_nil response.root.get_elements('//LoginResult')[0]
  end
  
  def test_successful_login_sets_ticket
    gateway = ModusPayGateway.new(fixtures(:modus_pay))
    
    assert_nil gateway.ticket
    response = gateway.send(:login)
    assert_not_nil gateway.ticket    
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
    gateway = ModusPayGateway.new(fixtures(:modus_pay))
    gateway.send(:login)
    
    response = gateway.send(:logoff)
    assert_match /LogoffResponse/, response
  end
end
