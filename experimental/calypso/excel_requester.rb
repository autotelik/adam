# Author::  Tom Statter
# Date::    Mar 2009
# 
# About::

require 'rubygems'
require 'thread'

require 'erb'
require 'data_server'
require 'requester_base'


class ExcelRequester < RequesterBase

  # TODO - if two requests are made at exactly the same time (same second) what happens !?
  # do we need to accept some id from the client to identify each feed ?
    
  def initialize( options = {} )
    super( options )
    @excel = JExcelFile.new
  end
 
  def request
    # open excel for request = File.join(@request_path, @request_name)
    begin
      @excel.open("C:\\SoftwareDev\\JRuby\\ADAM\\test\\fixtures\\FXRatesfromABSA_20090310.xls")
    rescue => e
      puts "EXCEL REQUEST FAILED #{e}"
    end
  end

  # Rtns : Map of [HEADER] => [COLUMN VALUES]
  #
  def get_response()
    # process excel - get the data segments - create hash with headers
    @data = {}

    sheet = @excel.sheet
    headers = []
    sheet.getRow(0).cellIterator.each do |h|
      headers << @excel.cell_value(h)
      @data[@excel.cell_value(h) ] = []
    end

    @excel.each_row do |row|
      row.cellIterator.each_with_index do |c, i|
        # N.B null row data can spill beyond the columns defined
        @data[headers[i]] << @excel.cell_value(c) if headers[i]
      end
    end
    @data
  end

  def unpack
    return @unpacked_file
  end
end