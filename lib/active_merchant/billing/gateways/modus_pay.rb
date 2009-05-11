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
      
      # def authorize(money, creditcard, options = {})
      #   post = {}
      #   add_invoice(post, options)
      #   add_creditcard(post, creditcard)        
      #   add_address(post, creditcard, options)        
      #   add_customer_data(post, options)
      #   
      #   commit('authonly', money, post)
      # end
      
      def purchase(money, check, options = {})
        commit('sale', build_transaction(money, check, options))
      end                       
    
      # def capture(money, authorization, options = {})
      #   commit('capture', money, post)
      # end
      
  private
    def build_request(action, body)
      xml = Builder::XmlMarkup.new
      
      xml.instruct!
      xml.tag! 'soap12:Envelope', ENVELOPE_NAMESPACES do
        add_ticket(xml)
        xml.tag! 'soap12:Body' do
          xml << body
        end
      end
      xml.target!
    end
    
    def build_transaction(money, check, options)
      xml = Builder::XmlMarkup.new
      
      xml.tag! 'ProcessACHTransaction', 'xmlns' => 'http://localhost/FTNIRDCService/' do
        add_check(xml, check, options)
        xml.amount amount(money)
      end
      
      
      # xml.tag! 'runTransaction', 'xmlns' => 'http://localhost/FTNIRDCService/' do
      #   xml.tag! 'token' do
      #   #   xml.tag! 'ClientIP', "replace me"
      #     xml.tag! 'PinHash' do
      #   #     xml.tag! 'HashValue', "replace me"
      #   #     xml.tag! 'Seed', "replace me"
      #   #     xml.tag! 'Type', "replace me"
      #     end
      #   #   xml.tag! 'SourceKey', "replace me"
      #   end
      #   xml.tag! 'req' do
      #     # xml.tag! 'AccountHolder', "replace me"
      #     # xml.tag! 'AuthCode', "replace me"
      #     add_address(xml, options)
      #     add_check(xml, check, options)
      #     # xml.tag! 'ClientIP', "replace me"
      #     # xml.tag! 'Command', "replace me" 
      #     add_customer_data(xml)
      #     add_details(xml, money)
      #     xml.tag! 'IgnoreDuplicate', false
      #     xml.tag! 'IgnoreDuplicateSpecified', false
      #     # xml.tag! 'RefNum', "replace me"
      #     # xml.tag! 'Software', "replace me"
      #     # <CreditCardData> 
      #     #   <AvsStreet>string</AvsStreet> 
      #     #   <AvsZip>string</AvsZip> 
      #     #   <CardCode>string</CardCode> 
      #     #   <CardExpiration>string</CardExpiration> 
      #     #   <CardNumber>string</CardNumber> 
      #     #   <CardPresent>boolean</CardPresent> 
      #     #   <CardPresentSpecified>boolean</CardPresentSpecified> 
      #     #   <CardType>string</CardType> 
      #     #   <CAVV>string</CAVV> 
      #     #   <DUKPT>string</DUKPT> 
      #     #   <ECI>string</ECI> 
      #     #   <InternalCardAuth>boolean</InternalCardAuth> 
      #     #   <InternalCardAuthSpecified>boolean</InternalCardAuthSpecified> 
      #     #   <MagStripe>string</MagStripe> 
      #     #   <MagSupport>string</MagSupport> 
      #     #   <Pares>string</Pares> 
      #     #   <Signature>string</Signature> 
      #     #   <TermType>string</TermType> 
      #     #   <XID>string</XID> 
      #     # </CreditCardData>
      #     # <RecurringBilling> 
      #     #   <Amount>double</Amount> 
      #     #   <Enabled>boolean</Enabled> 
      #     #   <Expire>string</Expire> 
      #     #   <Next>string</Next> 
      #     #   <NumLeft>string</NumLeft> 
      #     #   <Schedule>string</Schedule> 
      #     # </RecurringBilling>
      #   end
      # end
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
        
        x = ssl_post(URL, xml.target!, {'Content-Type'=> 'application/soap+xml; charset=utf-8'})
        puts x
        response = doc = REXML::Document.new(x)
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
      
      def add_customer_data(xml)
        # xml.tag! 'CustomerID', "replace me"
        # xml.tag! 'CustReceipt', false
        # xml.tag! 'CustReceiptSpecified', false
      end
      
      def add_details(xml, money)
        xml.tag! 'Details' do
          xml.tag! 'Amount', amount(money)
          # xml.tag! 'AmountSpecified', false
          # xml.tag! 'Clerk', "replace me"
          xml.tag! 'Currency', currency(money)
          # xml.tag! 'Description', "replace me"
          # xml.tag! 'Comments', "replace me"
          # xml.tag! 'Discount', 2.22
          # xml.tag! 'DiscountSpecified', true
          # xml.tag! 'Invoice', "replace me"
          # xml.tag! 'NonTax', false
          # xml.tag! 'NonTaxSpecified', false
          # xml.tag! 'OrderID', "replace me"
          # xml.tag! 'PONum', "replace me"
          # xml.tag! 'Shipping', 6.66
          # xml.tag! 'ShippingSpecified', true
          # xml.tag! 'Subtotal', 23.12
          # xml.tag! 'SubtotalSpecified', true
          # xml.tag! 'Table', "replace me"
          # xml.tag! 'Tax', 1.11
          # xml.tag! 'TaxSpecified', true
          # xml.tag! 'Terminal', "replace me"
          # xml.tag! 'Tip', 2.34
          # xml.tag! 'TipSpecified', true
        end
      end

      def add_address(xml, options)
        if billing_address = options[:billing_address] || options[:address]
          xml.tag! 'BillingAddress' do
            xml.tag! 'City', billing_address[:city]
            # xml.tag! 'Company', "replace me"
            xml.tag! 'Country', billing_address[:country]
            xml.tag! 'Email', options[:email]
            xml.tag! 'Fax', billing_address[:fax]
            xml.tag! 'FirstName', billing_address[:name]
            # xml.tag! 'LastName', "replace me"
            xml.tag! 'Phone', billing_address[:phone]
            xml.tag! 'State', billing_address[:state]
            xml.tag! 'Street', billing_address[:address1]
            xml.tag! 'Street2', billing_address[:address2]
            xml.tag! 'Zip', billing_address[:zip]
          end
        end
        
        if shipping_address = options[:shipping_address] || options[:address]
          xml.tag! 'BillingAddress' do
            xml.tag! 'City', shipping_address[:city]
            # xml.tag! 'Company', "replace me"
            xml.tag! 'Country', shipping_address[:country]
            xml.tag! 'Email', options[:email]
            xml.tag! 'Fax', shipping_address[:fax]
            xml.tag! 'FirstName', shipping_address[:name]
            # xml.tag! 'LastName', "replace me"
            xml.tag! 'Phone', shipping_address[:phone]
            xml.tag! 'State', shipping_address[:state]
            xml.tag! 'Street', shipping_address[:address1]
            xml.tag! 'Street2', shipping_address[:address2]
            xml.tag! 'Zip', shipping_address[:zip]
          end
        end
      end

      def add_invoice(post, options)
      end
      
      def add_check(xml, check, options)
        # <proc_inst>string</proc_inst>
        # <settlement>string</settlement>
        # <as_of_date>string</as_of_date>
        # <deposit_date>string</deposit_date>
        # <bank_name>string</bank_name>
        xml.account_number check.account_number
        xml.aba_number check.routing_number
        xml.status 'A'
        xml.name1 check.first_name
        xml.name2 check.last_name
        # xml.deposit_date, Date.today.strftime("%m/%d/%Y")
      end
      
      def parse(body)
        response = {}
        
        doc = REXML::Document.new(body)
        
        doc.root.elements.each do |element|
          response[element.name.to_sym] = element.text
        end
        
        response
      end     
      
      def commit(action, request)
        login
        request = build_request(action, request)
        puts "Request " + "*" * 50
        puts request
        response = ssl_post(URL, request, {'Content-Type'=> 'application/soap+xml; charset=utf-8'})
        puts "Response " + "*" * 50
        puts response
        result = parse(response)
        logoff
        result
      end

      def message_from(response)
      end
      
      def post_data(action, parameters = {})
      end
    end
  end
end

