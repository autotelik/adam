# Author::    Tom Statter 
# Date::      Aug 2008
# Details::   An FX Option requester
#             Enables an ad hoc upload of BBG data based on list of FXOption quote names,
#             and a set of request fields.

require 'rubygems'

require 'bloomberg_requester'
require 'quote_updater'
require 'bond_enumerable'

import com.calypso.tk.core.Log
import com.calypso.tk.core.Defaults

# The FeedAddress class, contains both a FeedAddress and a QuoteName
# 
# BBG requires the FeedAddress.FeedAddress. 
# We only want to process "FXOption" so supply filter
# that checks that FeedAddress.QuoteName contains ...  'FXOptions..'

# Create a new Updater - based on above requirements

DEFAULT_FX_FEED_ADDRESS = "BloombergDataLicience"     # yes this is correct - was mis-spelt by whoever created mappings !
  
def get_bbg_fx_quotes()
 
  print "Starting FX VOL Quote Update from BBG"
  
  updater = QuoteUpdater.new( DEFAULT_FX_FEED_ADDRESS ) do |f| 
    f.getQuoteName.include?("FXOption.")
  end

  if updater.feed_address_address.size == 0
    Log.error(Log::ERROR, "No updates - No Mappings found for Feed Address #{DEFAULT_FX_FEED_ADDRESS}")
    return false
  end
   
  @request_fields = ['NAME','PX_BID','PX_ASK','PX_OPEN','PX_LAST','PX_HIGH','PX_LOW', 'LAST_UPDATE']

  begin
    # BBG needs the FeedAddress.FeedAddress (not the QuoteName)
    @bbg_return_data = updater.request_updata_data( updater.feed_address_address, @request_fields )
  rescue Exception => e
    Log.error(Log::ERROR, "FX VOL Update failed in BBG ftp request and processing")
    raise 
  end

  # Create mapping between Calypso method to call on QuoteValue and the associated request field
  #
  @quote_value_map = {'setBid' => 'PX_BID', 'setAsk' => 'PX_ASK', 
                      'setOpen' => 'PX_OPEN', 'setClose' => 'PX_LAST',
                      'setHigh' => 'PX_HIGH', 'setLow' => 'PX_LOW', 'setLast' => 'PX_LAST'}

  updater.quote_factor = 100        # BBG values need dividing by 100

  date = JDate.getNow
    
  Log.info(Log::INFO, "Saving [#{@bbg_return_data.size}] FX Vols Quotes AsOfDate #{date.inspect}" )
  
  @bbg_return_data.each do |quote|

    quote.slice!(1,3)    # NOTE : Fields 1,2,3 are extra junk we did not request - remove

    # Create mapping hash between request field and resulting data item : e.g. 'PX_OPEN' => 1.01
    @quote_data = Hash[*@request_fields.zip(quote).flatten]

    # Now get reverse mapping back from the BBG required FeedAddress to the Calypso QuoteName
    quote_name = updater.feed_quote_map[ @quote_data['NAME'] ]
    if(quote_name)
      updater.set_quote( quote_name, @quote_data, @quote_value_map, QuoteValue::YIELD, date )

    else
      log :warning, "No Quote found for #{quote_name}"
    end
  end

  Log.info(Log::INFO, "FX VOL Quote Update Finished" )
    
end
