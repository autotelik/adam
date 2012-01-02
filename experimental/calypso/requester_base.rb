# Author::  Tom Statter
# Date::    Mar 2009
# 
# About::   Base class to handle a MarketData request.
#           Connect to a source unpack into standard form ready for actual load
#           into Calypso
#
# =>        TODO - Needs productionising - where config and env detials come from etc

#require 'rubygems'
#require 'thread'
#require 'erb'

class RequesterBase

  def initialize(options = {})
    @unpacked_file = nil
  end
 
  # What : Go to source and request market data
  def request
  end

  # What : Get the raw  market data from the source
  def get_response
    return @unpacked_file
  end

  # What : Unpack the raw market data finto expected format
  def unpack
    return @unpacked_file
  end
  
end