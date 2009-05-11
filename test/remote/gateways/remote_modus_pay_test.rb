require File.dirname(__FILE__) + '/../../test_helper'

class RemoteModusPayTest < Test::Unit::TestCase
  

  def setup
    @gateway = ModusPayGateway.new(fixtures(:modus_pay))
    
    @amount = 100
    @check = check
    
    @options = {
    }
  end
  
  def test_successful_check_purchase
    response = @gateway.purchase(@amount, @check, @options)
    
    assert_match /ProcessACHTransactionResult/, response
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
