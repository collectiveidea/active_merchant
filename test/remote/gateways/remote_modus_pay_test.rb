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
    assert_not_nil response.root.get_elements('//ProcessACHTransactionResult')[0]
  end
  
  def test_unsuccessful_check_purchase
    @check.routing_number = ""
    
    response = @gateway.purchase(@amount, @check, @options)
    assert_nil response.root.get_elements('//ProcessACHTransactionResult')[0]
  end  
  
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
