# Copyright:: (c) Tom Statter for Autotelik Media Ltd 2011
# Author ::   Tom Statter
# Date ::     July 2011
# License::   Dual license : permission given to use this code under two licenses.
# => TBD one license (probably GPL) for free (no cost) programs
# => TBD one for commercial programs
#
require 'project' 
require 'asset'
require 'calypso_system'


class AdamModel
  
  attr_accessor :project_list, :selected_project_index

  # asset returns the currently selected asset
  
  attr_accessor :assets, :filtered_assets, :selected_asset_index, :asset, :asset_filter_text
  
  attr_reader   :projects

  attr_accessor :output_text

  attr_accessor :working_tab_index, :working_tab_name


  # N.B - Called by controller to create variable (@__model) but also
  # Called every time controller calls view_state, which returns
  # a new instance of the model - so keep as light as possible
  def initialize

    puts "IN model : initialize #{self.class}"
    @projects = []

    @selected_project_index = 0
    @asset = nil
                  
    @assets = []
    @filtered_assets = []
    @selected_asset_index = 0

    @asset_filter_text = String.new
    
    @output_text = String.new
    puts "OUT model - initialize"
  end
  
  def current_project
    @projects[@selected_project_index]
  end

  # Initialise the top level list of Projects, and load associated Assets
  
  def load_projects( select_options = nil )
    puts "IN AdamModel - load_projects"
    @project_list = []
    @projects = Project.find(:all, :order => :name)
    @project_list = @projects.collect { |t| t.name } 
    @selected_project_index = 0
    @selected_asset_index = 0
    unless(select_options && select_project(select_options) )
      load_assets_and_filter
    end
    puts "OUT load_projects"
  end


  # If valid index to project list supplied, make that project current,
  # and load associated Assets
  # Currently supports select via :index => int or :name => project.name
  #
  def select_project( options )
    index  = nil
    
    if(options[:index] ) 
      index = options[:index] if @projects.size > options[:index]
    elsif(options[:name])
      index = @project_list.index(options[:name])
    end

    puts "IN AdamModel - select_project found index : #{index}"
    
    if( index )
      @selected_project_index = index
      @selected_asset_index = 0
      load_assets_and_filter
      return true
    end

    return false
  end

  # Assign current Asset from Navigation Asset List
  
  def select_asset( index )
    puts "in select_asset"
    if @assets.size > index
      @asset = @assets[ index ]
      @selected_asset_index = index
    end
  end
  
  # Assign seleced Project's Asset list to current Asset list
  # and apply filter to
  # (whenever a Project selected)
  
  def load_assets_and_filter()
  
    #puts "IN AdamModel - load_assets"
    
    if(@projects.size > @selected_project_index)
      puts "Find assets @ #{@selected_project_index}"
   
      # One list contains all assets for the project, User can filter the other by name
      @assets = @projects[ @selected_project_index ].assets(true) # don't use cache - force reload
      
      refilter

      # The currently selected
      if @assets.empty?
        @selected_asset_index = -1
        @asset = nil
      else
        @selected_asset_index = 0
        @asset = @filtered_assets[0]
      end
      puts "Current asset #{@asset.inspect}"
    end
  end

  #################
  # ASSET FILTERING
  #################
  
  def asset_filter_text=( txt )
    @asset_filter_text = txt
    puts "IN model : asset_filter_text : [#{@asset_filter_text}]"
    refilter
  end

  # Set current asset pointer to asset @ index in the filtered list

  def select_filtered_asset( index )
    if(index > 0 && @filtered_assets.size > index)
      @asset = @filtered_assets[ index ]
      @selected_asset_index = index
    end
  end
  
  def refilter
    if(@asset_filter_text.empty? or @asset_filter_text.nil?)
      @filtered_assets = @assets
    else
      @filtered_assets = []
      @assets.each do |a|
        @filtered_assets << a if(a.name.include?(@asset_filter_text))
      end
    end
  end
        
  # Fire up Excel and display schema

  def spawn_excel
    raise "No Asset selected for export to Excel" unless @asset
    xl = ExcelSystem.new
    xl.spawn( @asset )
  end

  # Create schema and return text for ADAM to display results

  def to_xml
    raise "No Asset selected for export to XML" unless @asset
    xml = XmlSystem.new
    @output_text = xml.export( @asset ).target!
  end
  

  def to_csv
    raise "No Asset selected for export to Calypso" unless @asset
    csv = CSVSystem.new
    @output_text = csv.export( @asset )
  end
  
  def to_calypso
    raise "No Asset selected for export to Calypso" unless @asset
    calypso = CalypsoSystem.new
    @output_text = calypso.export( @asset ).target!
  end
  
end
