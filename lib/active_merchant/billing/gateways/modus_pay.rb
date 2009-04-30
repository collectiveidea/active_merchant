module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class ModusPayGateway < Gateway
      URL = 'https://www.ftnirdc.com/RDCServices/FTNIRDCservice.asmx'
      
      TEST_LOGIN = {:login => "testaccountuser@TEST", :password => "01password"}
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['US']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.moduspay.com/'
      
      # The name of the gateway
      self.display_name = 'ModusPay'
      
      ENVELOPE_NAMESPACES = { 'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
                              'xmlns:soap12' => 'http://www.w3.org/2003/05/soap-envelope',
                              'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
                            }
      
      attr_accessor :ticket
      
      def initialize(options = {})
        requires!(options, :login, :password)
        @options = options
        super
      end  
      
      def authorize(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_address(post, creditcard, options)        
        add_customer_data(post, options)
        
        commit('authonly', money, post)
      end
      
      def purchase(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_address(post, creditcard, options)   
        add_customer_data(post, options)
             
        commit('sale', money, post)
      end                       
    
      def capture(money, authorization, options = {})
        commit('capture', money, post)
      end
      
    private
    def build_request(action, body)
      xml = Builder::XmlMarkup.new
      
      xml.instruct!
      xml.tag! 'soap12:Envelope', ENVELOPE_NAMESPACES do
        add_ticket(xml)
      end
      xml.tag! 'runTransaction', 'xmlns' => 'http://localhost/FTNIRDCService/' do
        xml.tag! 'token' do
          xml.tag! 'ClientIP', "replace me"
          xml.tag! 'PinHash' do
            xml.tag! 'HashValue', "replace me"
            xml.tag! 'Seed', "replace me"
            xml.tag! 'Type', "replace me"
          end
          xml.tag! 'SourceKey', "replace me"
        end
        xml.tag! 'req' do
          xml.tag! 'AccountHolder', "replace me"
          xml.tag! 'AuthCode', "replace me"
          xml.tag! 'BillingAddress' do
            xml.tag! 'City', "replace me"
            xml.tag! 'Company', "replace me"
            xml.tag! 'Country', "replace me"
            xml.tag! 'Email', "replace me"
            xml.tag! 'Fax', "replace me"
            xml.tag! 'FirstName', "replace me"
            xml.tag! 'LastName', "replace me"
            xml.tag! 'Phone', "replace me"
            xml.tag! 'State', "replace me"
            xml.tag! 'Street', "replace me"
            xml.tag! 'Street2', "replace me"
            xml.tag! 'Zip', "replace me"
          end
          xml.tag! 'CheckData' do
            xml.tag! 'Account', "replace me"
            xml.tag! 'AccountType', "replace me"
            xml.tag! 'CheckNumber', "replace me"
            xml.tag! 'DriversLicense', "replace me"
            xml.tag! 'DriversLicenseState', "replace me"
            xml.tag! 'RecordType', "replace me"
            xml.tag! 'Routing', "replace me"
            xml.tag! 'SSN', "replace me"
          end
          xml.tag! 'ClientIP', "replace me"
          xml.tag! 'Command', "replace me"
          # <CreditCardData> 
          #   <AvsStreet>string</AvsStreet> 
          #   <AvsZip>string</AvsZip> 
          #   <CardCode>string</CardCode> 
          #   <CardExpiration>string</CardExpiration> 
          #   <CardNumber>string</CardNumber> 
          #   <CardPresent>boolean</CardPresent> 
          #   <CardPresentSpecified>boolean</CardPresentSpecified> 
          #   <CardType>string</CardType> 
          #   <CAVV>string</CAVV> 
          #   <DUKPT>string</DUKPT> 
          #   <ECI>string</ECI> 
          #   <InternalCardAuth>boolean</InternalCardAuth> 
          #   <InternalCardAuthSpecified>boolean</InternalCardAuthSpecified> 
          #   <MagStripe>string</MagStripe> 
          #   <MagSupport>string</MagSupport> 
          #   <Pares>string</Pares> 
          #   <Signature>string</Signature> 
          #   <TermType>string</TermType> 
          #   <XID>string</XID> 
          # </CreditCardData> 
          xml.tag! 'CustomerID', "replace me"
          xml.tag! 'CustReceipt', false
          xml.tag! 'CustReceiptSpecified', false
          xml.tag! 'Details' do
            xml.tag! 'Amount', 11.11
            xml.tag! 'AmountSpecified', false
            xml.tag! 'Clerk', "replace me"
            xml.tag! 'Currency', "replace me"
            xml.tag! 'Description', "replace me"
            xml.tag! 'Comments', "replace me"
            xml.tag! 'Discount', 2.22
            xml.tag! 'DiscountSpecified', true
            xml.tag! 'Invoice', "replace me"
            xml.tag! 'NonTax', false
            xml.tag! 'NonTaxSpecified', false
            xml.tag! 'OrderID', "replace me"
            xml.tag! 'PONum', "replace me"
            xml.tag! 'Shipping', 6.66
            xml.tag! 'ShippingSpecified', true
            xml.tag! 'Subtotal', 23.12
            xml.tag! 'SubtotalSpecified', true
            xml.tag! 'Table', "replace me"
            xml.tag! 'Tax', 1.11
            xml.tag! 'TaxSpecified', true
            xml.tag! 'Terminal', "replace me"
            xml.tag! 'Tip', 2.34
            xml.tag! 'TipSpecified', true
          end
          xml.tag! 'IgnoreDuplicate', false
          xml.tag! 'IgnoreDuplicateSpecified', false
          # <RecurringBilling> 
          #   <Amount>double</Amount> 
          #   <Enabled>boolean</Enabled> 
          #   <Expire>string</Expire> 
          #   <Next>string</Next> 
          #   <NumLeft>string</NumLeft> 
          #   <Schedule>string</Schedule> 
          # </RecurringBilling>
          xml.tag! 'RefNum', "replace me"
          xml.tag! 'ShippingAddress' do
            xml.tag! 'City', "replace me"
            xml.tag! 'Company', "replace me"
            xml.tag! 'Country', "replace me"
            xml.tag! 'Email', "replace me"
            xml.tag! 'Fax', "replace me"
            xml.tag! 'FirstName', "replace me"
            xml.tag! 'LastName', "replace me"
            xml.tag! 'Phone', "replace me"
            xml.tag! 'State', "replace me"
            xml.tag! 'Street', "replace me"
            xml.tag! 'Street2', "replace me"
            xml.tag! 'Zip', "replace me"            
          end
          xml.tag! 'Software', "replace me"
        end
      end
      xml.target!
    end
    
      # <?xml version="1.0" encoding="utf-8"?>
      # <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
      #   <soap12:Body>
      #     <Login xmlns="http://localhost/FTNIRDCService/">
      #       <username>string</username>
      #       <password>string</password>
      #     </Login>
      #   </soap12:Body>
      # </soap12:Envelope>
      def login
        xml = Builder::XmlMarkup.new
        
        xml.instruct!
        xml.tag! 'soap12:Envelope', ENVELOPE_NAMESPACES do
          xml.tag! 'soap12:Body' do
            xml.tag! 'Login', 'xmlns' => 'http://localhost/FTNIRDCService/' do
              xml.tag! 'username', @options[:login]
              xml.tag! 'password', @options[:password]
            end
          end
        end
        
        response = doc = REXML::Document.new(ssl_post(URL, xml.target!, {'Content-Type'=> 'application/soap+xml; charset=utf-8'}))
        @ticket = doc.root.get_text('//Ticket')
        response
      end
      
      # <?xml version="1.0" encoding="utf-8"?>
      # <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
      #   <soap12:Header>
      #     <TicketHeader xmlns="http://localhost/FTNIRDCService/">
      #       <Ticket>string</Ticket>
      #     </TicketHeader>
      #   </soap12:Header>
      #   <soap12:Body>
      #     <Logoff xmlns="http://localhost/FTNIRDCService/" />
      #   </soap12:Body>
      # </soap12:Envelope>
      def logoff
        xml = Builder::XmlMarkup.new
        
        xml.instruct!
        xml.tag! 'soap12:Envelope', ENVELOPE_NAMESPACES do
          add_ticket(xml)
          xml.tag! 'soap12:Body' do
            xml.tag! 'Logoff', 'xmlns' => 'http://localhost/FTNIRDCService/'
          end
        end
        ssl_post(URL, xml.target!, {'Content-Type'=> 'application/soap+xml; charset=utf-8'})
      end
      
      def add_ticket(xml)
        xml.tag! 'soap12:Header' do
          xml.tag! 'TicketHeader', 'xmlns' => 'http://localhost/FTNIRDCService/' do
            xml.tag! 'Ticket', ticket
          end
        end
      end
      
      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)      
      end

      def add_invoice(post, options)
      end
      
      def add_creditcard(post, creditcard)      
      end
      
      def parse(body)
        response = {}
        
        doc = REXML::Document.new(body)
        
        doc.root.elements.each do |element|
          response[element.name.to_sym] = element.text
        end
        
        response
      end     
      
      def commit(action, money, parameters)
        login
        response = parse(ssl_post(URL, build_request(action, request), {'Content-Type'=> 'application/soap+xml; charset=utf-8'}))
        logoff
      end

      def message_from(response)
      end
      
      def post_data(action, parameters = {})
      end
    end
  end
end

