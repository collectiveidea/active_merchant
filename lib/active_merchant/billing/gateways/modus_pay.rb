module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class ModusPayGateway < Gateway
      TEST_URL = 'https://example.com/test'
      LIVE_URL = 'https://example.com/live'
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['US']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.moduspay.net/'
      
      # The name of the gateway
      self.display_name = 'Modus Pay'
      
      ENVELOPE_NAMESPACES = { 'xmlns:xsi'  => 'http://www.w3.org/2001/XMLSchema-instance',
                              'xmlns:xsd'  => 'http://www.w3.org/2001/XMLSchema',
                              'xmlns:soap' => 'http://www.w3.org/2003/05/soap-envelope'
                            }
      def initialize(options = {})
        #requires!(options, :login, :password)
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

      def purchase(money, payment_source, options = {})
        post = {}
        add_invoice(post, options)
        add_payment_source(post, payment_source, options)        
        add_address(post, payment_source, options)   
        add_customer_data(post, options)
        commit('sale', money, post)
      end
    
      # def capture(money, authorization, options = {})
      #   commit('capture', money, post)
      # end
    
      private
      
      def build_request(action, body)
        xml = Builder::XmlMarkup.new
        
        xml.instruct!
        xml.tag! 'soap:Envelope', ENVELOPE_NAMESPACES do
          xml.tag! 'soap:Header' do
            xml.tag! 'TicketHeader', :xmlns => "http://localhost/FTNIRDCService/" do
              xml.tag! 'Ticket', value
            end
          end
          xml.tag! 'soap:Body' do
            xml.tag! 'n1:SendAndCommit', SEND_AND_COMMIT_ATTRIBUTES do
              xml.tag! 'SendAndCommitSource', SEND_AND_COMMIT_SOURCE_ATTRIBUTES do
                add_credentials(xml)
                add_transaction_type(xml, action)
                xml << body
              end
            end
          end
        end
        xml.target!
      end
      
      
      
      # def add_customer_data(post, options)
      # end
      # 
      # def add_address(post, creditcard, options)      
      # end
      # 
      # def add_invoice(post, options)
      # end
      # 
      # def add_payment_source(params, source, options={})
      #   case determine_funding_source(source)
      #   when :vault       then add_customer_vault_id(params, source)
      #   when :credit_card then add_creditcard(params, source, options)
      #   when :check       then add_check(params, source)
      #   end
      # end
      # 
      # def parse(body)
      # end     
      # 
      # def commit(action, money, parameters)
      # end
      # 
      # def message_from(response)
      # end
      # 
      # def post_data(action, parameters = {})
      # end
    end
  end
end

