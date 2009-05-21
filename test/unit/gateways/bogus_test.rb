require File.dirname(__FILE__) + '/../../test_helper'

class BogusTest < Test::Unit::TestCase
  def setup
    @gateway = BogusGateway.new(
      :login => 'bogus',
      :password => 'bogus'
    )
    
    @creditcard = credit_card('1')
    @check = check(:account_number => '1')
    
    @response = ActiveMerchant::Billing::Response.new(true, "Transaction successful", :transid => BogusGateway::AUTHORIZATION)
  end

  def test_authorize
    assert @gateway.capture(1000, @creditcard).success?
  end

  def test_purchase
    assert @gateway.purchase(1000, @creditcard).success?   
  end
  
  def test_purchase_check
    assert @gateway.purchase(1000, @check).success?
  end

  def test_credit
    assert @gateway.credit(1000, @response.params["transid"]).success?
  end

  def test_void
    assert @gateway.void(@response.params["transid"]).success?
  end
  
  def  test_store
    assert @gateway.store(@creditcard).success?
  end
  
  def test_unstore
    assert @gateway.unstore('1').success?
  end
  
  def test_supported_countries
    assert_equal ['US'], BogusGateway.supported_countries
  end
  
  def test_supported_card_types
    assert_equal [:bogus], BogusGateway.supported_cardtypes
  end
end
