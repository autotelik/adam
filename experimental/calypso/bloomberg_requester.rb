# Author::  Tom Statter, Andy Griffiths
# Date::    Aug 2008
# 
# About::   Quick n Dirty class to build request, connect & decrypt from BBG ftp site
# =>        TODO - Needs productionising - where config and env detials come from etc

require 'rubygems'
require 'thread'

require 'erb'
require 'bloomberg_ftp'
require 'bloomberg_decrypt'
require 'data_server'

class BloombergRequester

  attr_accessor :bbg_request, :decrypt_file, :reply_file_name
  
  RequestPath           = File.join(ENV['CALYPSO_HOME'],  'calypsox\\bloomberg')
  RequestTemplate       = File.join(ENV['CALYPSO_HOME'],  'calypsox\\tools\\templates\\bbg_request_template.erb')
  
  # TODO - if two requests are made at exactly the same time (same second) what happens !?
  # do we need to accept some id from the client to identify each feed ?
    
  def initialize(request_data, request_fields, options = {} )
    @request_path   = options[:request_path]   || RequestPath
    @sleep_duration = options[:sleep_duration] || 60   # in seconds
    
    FileUtils.mkdir_p(@request_path) unless File.exists?(@request_path)
    
    if DataServer.instance.connected?
      @max_tries = DataServer.instance.getRemoteAccess.getEnvProperties.getProperty('SAVE_QUOTE_BBG_MAX_TRIES').to_i
    end
  
    @max_tries    = 10 unless( @max_tries && @max_tries > 0 )
    @decrypt_file = nil
    
    begin 
      File.open( RequestTemplate ) do |template|
        @bbg_request_template = ERB.new(template.read)
      end 
    rescue => e
      raise "Cannot open or read template #{e}"
    end

    prepare_request_file(request_data, request_fields)
    
    @bbg_ftp = BloombergFTP.new()
    @bbg_ftp.passive = true
    @bbg_ftp.debug_mode = options[:debug_mode] || false
    
    @decrypter = BloombergDecrypt.new()
  end
 
  def prepare_request_file(request_data, request_fields)
    @request_data = request_data
    @request_fields = request_fields
    
    @request_name = "vtbc_#{Time.now.strftime("%H%M%S%d%m%y")}.req"

    @reply_file_name = @request_name.sub('req', 'out.enc')
    
    # Create our specific bbg request file from the template
    @bbg_request = @bbg_request_template.result(binding)
  end
   
  def request
  
    begin
      request = File.join(@request_path, @request_name)
      
      File.open( request, "w" ) do |outfile|
        outfile << @bbg_request
      end 

      @bbg_ftp.open if(@bbg_ftp.closed?)
      @bbg_ftp.passive = true
      
      @bbg_ftp.put(request)
    rescue => e
      print "ERROR : #{e.message}"
      raise "Cannot access request : #{request} : #{e}"
    end
    
    print "Sent request file : #{@request_name}"
  end

  # What : Poll Bloomberg for a response file.
  # If file found within time out, gets the file, decrypts it and writes
  # the decrpted results file to file storage.
  # Args : An optional path for results file. Default is current directory
  
  def get_response( path = @request_path)
    
    FileUtils.mkdir_p(path) unless File.exists?(path)

    @decrypt_file = nil
    
    reply = File.join( path, @reply_file_name )
    
    @bbg_ftp.open if(@bbg_ftp.closed?)
    
    # The FTP read thread
    
    find = Thread.new {
      print "Searching for response file : #{@reply_file_name}"
      while( true )
        begin
            @bbg_ftp.passive = true
            @bbg_ftp.getbinaryfile( @reply_file_name, reply)
            @bbg_ftp.close
            print "Downloaded response file : #{@reply_file_name}"
            break;
        rescue => e
          #  If the file is not found, throws an exception, so only hits call to close() if succesful
          sleep( @sleep_duration )
        end
      end
    }
    
    # On 64 bit Win had probs with getbinaryfile and list hanging in the ftp call - causing
    # whole scheduled task to hang and requiring engine to be bounced.
    # 
    # This is basic attempt to separate the possible hanging call into separate thread that we
    # can kill rather than whole job hanging
    #
    (1..@max_tries).each {|i| 
      puts "\nSearch attempt #{i} of #{@max_tries}"
      sleep(@sleep_duration)
      break if(@bbg_ftp.closed? )
    }
    
    unless(@bbg_ftp.closed? && File.exists?(reply) )
      Log.error(Log::CALYPSOX, "ERROR : FTP get time out")
      raise "ERROR : TIMEOUT - Couldn't find or open file : #{@reply_file_name}"
    end

    begin
      @decrypt_file = File.join( path, @reply_file_name.sub('out.enc', 'out') )
      @decrypter.decrypt( reply, @decrypt_file)     
    rescue => e
      Log.error(Log::CALYPSOX, "#{e.message}")
      raise "ERROR Failed to decrypt response file #{reply}"
    end     
    return @decrypt_file
  end

  def unpack
    BloombergRequester::get_data_segment( @decrypt_file )
  end

  # Supply the name of the BBG decrypted file. 
  # Returns the data segment only.
  # 
  def self::get_data_segment( file )
     data = []
    begin
      File.open(file) do |f|
      f.each do |line|
        data << line.split('|') if(/START-OF-DATA\n/ =~ line)..(/END-OF-DATA\n/ =~ line) 
      end
     end
    rescue => e
      print "Cannot open BBG file to get data segment : #{file}"
      raise
    end
     data.shift     # remove the start-of-data and the end-of-data lines
     data.pop
     data || []
  end
  
end
