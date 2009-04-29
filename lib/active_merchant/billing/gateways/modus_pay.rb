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
              xml.tag! 'username', options[:username]
              xml.tag! 'password', options[:password]
            end
          end
        end
        
        return ssl_post(URL, xml.target!, {'Content-Type'=> 'application/soap+xml; charset=utf-8'})
        
        response = parse(ssl_post(URL, xml.target!, {'Content-Type'=> 'application/soap+xml; charset=utf-8'}))
        @ticket = response[:ticket]
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
          xml.tag! 'soap12:Header' do
            xml.tag! 'TicketHeader', 'xmlns' => 'http://localhost/FTNIRDCService/' do
              xml.tag! 'Ticket', ticket
            end
          end
          xml.tag! 'soap12:Body' do
            xml.tag! 'Logoff', 'xmlns' => 'http://localhost/FTNIRDCService/'
          end
        end
        xml.target!
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

