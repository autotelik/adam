require 'data_server'

include_class com.calypso.tk.marketdata.QuoteValue
include_class com.calypso.tk.marketdata.QuoteSet
include_class com.calypso.tk.core.JDate
include_class com.calypso.tk.core.JDatetime
include_class java.lang.IndexOutOfBoundsException
import com.calypso.tk.core.Log

class QuoteUpdater
  
  attr_accessor :remotemarketdata, :quote_set, :bbg_update_data
  attr_accessor :feed_address, :feed_address_list, :feed_quote_map
 
  attr_accessor :quote_factor      # Incoming data often needs scaling (see quote_factor_operator)
  
  DEFAULT_PRICING_ENV = "default"  

  # EXAMPLE CALL
  # TODO - if two requests are made at exactly the same time what happens !?
    # do we need to pass some id to BloombergRequester to identify each feed ?
    #requester = BloombergRequester.new(request_data, request_fields)


  # Accepts an optional filter block to refine the FeedAddress list we want to process
  # Example : To find CDS FeedAddresses on the ReutersClient feed ...
  #  updater = QuoteUpdater.new( "ReutersClient" ) { |f| f.getQuoteName.include?("CDS.") }
  #
  def initialize( requester, feed_address = nil, pricer = DEFAULT_PRICING_ENV, &filter)

    @requester             = requester
    @quote_factor          = nil
    @quote_factor_operator = '/'
    
    @ds = DataServer.instance
  
    @feed_address = feed_address
    
    @remotemarketdata = @ds.getRemoteMarketData()
        
    @quote_set = @remotemarketdata.getPricingEnv(pricer).getQuoteSet() 
   
    @bbg_update_data = []
    
    if block_given? 
      filter_addresses( &filter )
    else
      get_all_feed_address
      feed_address_to_quote_map      
    end   
  end
  

  # Filter the FeedAddress list based on supplied block
  # e.g To only process when QuoteName contains FXOptions ,supply block :
  #     { |f| f.getQuoteName.include?("FXOption.") }
   
  def filter_addresses( &filter_proc )
    get_all_feed_address
    @feed_address_list = @feed_address_list.find_all { |fa| filter_proc.call( fa ) }  
    feed_address_to_quote_map    
  end
  
  
  # Create map of {feed address => quote }
  # NOTE - This is incorrect -  not a 1-1 mapping but a 1-MANY
  #  .. too much regression to change now should be an Array of QuoteNames
  #  @feed_quote_map[fa.getFeedAddress] = [fa.getQuoteName, ...  ]
  # 
  def feed_address_to_quote_map
    @feed_quote_map = {}
    @feed_address_list.each {|fa| @feed_quote_map[fa.getFeedAddress] = fa.getQuoteName }  
  end

  # Returns list of all FeedAddress -> getQuoteName
  def quote_names
    @feed_quote_map.values 
  end

  # Returns list of all FeedAddress -> getFeedAddress
  def feed_address_address
    @feed_quote_map.keys
  end

  # Create FeedAddress list which client wants to update
  # Expects a block e.g  { |f| f.getQuoteName.include?("FXOption.") }
  #
  def find_all_feed_address()
    farray = @feed_address_list.find_all { |f| yield f } # Array of FeedAddress
    farray.collect { |f| f.getFeedAddress }
  end
  
  # Find a particular FeedAddress object
  # 
  def lookup_feed_address( name )
    @feed_address_list.find { |f| f.getFeedAddress.include?(name) }
  end
  
  
  # Sets quotes for a standard BBG response file - Use a mapping from BBG Fields
  # quote_data contains a hash of BBG FieldName > Data (value)
  # quote_method_map contains a hash of QuoteValue method to BBG FieldName e.g  'setBid' => 'QUOTE_BID'
  # type is type Field from com.calypso.tk.marketdata.QuoteValue e.g QuoteValue::YIELD 
  
  def set_quote( name, quote_data, quote_method_map, type, date = JDate.getNow )
    
    begin
        qv = QuoteValue.new( @quote_set.getName, name, date, type )

        result = @remotemarketdata.getQuoteValue(qv)

        result = qv if result.nil?    # Nothing found, create a new one
        
        # Call method, e.g setAsk, on QuoteValue passing in corresponding value
        
        quote_method_map.each do |method, bbg|  
          data = quote_data[bbg]
           
          if data.nil? || data.empty?
           print "WARNING - No value returned for Quote #{name} field #{bbg}" 
           Log.warn(Log::WARN, "No value returned for Quote #{name} field #{bbg}" )
           next 
          end 
          
          if data.include?( 'N.A' )       # Do not create an entry if no quote available
           print "WARNING - N.A value returned for Quote #{name} field #{bbg}"
           Log.warn(Log::WARN, "N.A value returned for Quote #{name} field #{bbg}" )
           next 
          end
                 
          if @quote_factor
            result.send( method, data.to_f.send( @quote_factor_operator, @quote_factor) )
          else
            result.send( method, data.to_f )
          end
        end
        
        result.setSourceName(@feed_address)
        
        saved = @remotemarketdata.save(result)

        unless(saved)
          Log.error(Log::CALYPSOX, "Error saving Quote #{name}")
        end
       
    rescue NativeException => e
        Log.error(Log::CALYPSOX, e.message)
    end
  end
  
  def request_updata_data( request_data, request_fields)
    
    begin 
      @requester.request
    rescue Exception => e
      Log.error(Log::ERROR, "Failed to send (ftp put) BBG request file : #{e.message}")
      raise "Failed to send (ftp put) BBG request file"
    end
    
    begin
      decrypted_file = @requester.get_response()
     
      @bbg_update_data = @requester.unpack()
      
    rescue Exception => e
      Log.error(Log::ERROR , "#{e.message}")
      raise "Failed to get and decrypt BBG response"
    end
    
    @bbg_update_data
  end

  # Helpers
  
  PERMITTED_OPERATORS = ['-', '+', '/', '*']
  
  # Set the operator applied to all values before storage factor by which all values are 
  def quote_factor_operator=( op )
     if( PERMITTED_OPERATORS.include?( op ) && (@quote_factor != 0 && op == "'/'") )
      @quote_factor_operator = op if PERMITTED_OPERATORS.include?( op )
     end
  end
  
 private
 
  def get_all_feed_address
    if @feed_address
      @feed_address_list = @remotemarketdata.getAllFeedAddress(@feed_address)
    else
      @feed_address_list = @remotemarketdata.getAllFeedAddress() 
    end
  end
  
end