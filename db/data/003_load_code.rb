# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#
# Usage : Should be called from database.rake tasks - which sorts out load paths, DB etc

module Adam
  
  module Loader

    l = Language.find_by_name( "JRuby")
    
    code =<<-EOF
    require 'src/calypso/data_server'

    module ComCalypsoTkCore
        include_package "com.calypso.tk.core"
    end
EOF
    # split up string interplotation or it will try to actually run it here as we store in DB !
    code << "args = ['-env', '#"
    code << "{event.getActionCommand}', '-user', 'calypso_user', '-password', 'calypso']\n"
    code << "@ds = DataServer.instance.connect( args, 'AdamConnection' )\n"

    Snippet.create(	:name => 'ConnectToCalypso', :group => 'Calypso', :language => l, :code => code, :private => true)

    code = "DataServer.instance.disconnect"
    
    Snippet.create(	:name => 'DisconnectFromCalypso', :group => 'Calypso', :language => l, :code => code, :private => true)


    code =<<-EOF
    datetime = ComCalypsoTkCore::JDatetime.new(ComCalypsoTkCore::JDate.getNow, 23, 59, 0, java.util.TimeZone.getDefault())

    filter = "ALL"

    @tradeFilter = @ds.getRemoteReferenceData().getTradeFilter(filter)

    if(tradeFilter.nil?)
      throw "Unable to get requested trade filter"
    end

    @trades = @ds.getRemoteTrade().getTrades(tradeFilter, datetime)
EOF

    Snippet.create(	:name => 'LoadTradeFilter', :group => 'Calypso', :language => l, :code => code)

    puts "#### CODE DATA LOAD COMPLETE ####"
  end
end    