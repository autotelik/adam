require 'system'
require 'jexcel_file'
require 'asset_data_store'

class ExcelSystem < System
	
  attr_accessor :excel
  
  # ActiveRecord class - don't use/create initialize(), use macro with callback

  after_initialize :initialize_excel

  def initialize_excel
   @excel = nil
  end

  
  # Create an Excel file representing supplied Asset
    
  def export(asset, filename)
   
    @excel = JExcelFile.new(asset.root.name)
    
    add_to_excel( asset.root, false )
    
    @excel.save( filename )  
  end

  # Fire up Excel application and create sheet(s) representing supplied Asset
  
  def spawn(asset, visible = true)

    if(Config::CONFIG["host_os"] =~ /^win|mswin/i)  # Windows specific code
      puts "START EXCEL SPAWN FOR ASSET #{asset.inspect}"
      @excel = JExcelWin32.new(1)
    
      @excel.visible( visible )
       
      @excel.active_sheet.setProperty('Name', asset.root.name)
    
      add_to_excel( asset.root, false )
    else
      # TODO - how best to de-activate or inform user Excel not available ?
    end
  end

  # Read Excel spreadsheet and populate Composer structure with values populated with Data
  #
  def populate( asset, filename, options = {} )

    asset.data_store = AssetDataStore.new( asset )
    
    @excel = JExcelFile.new
    @excel.open( filename )

    # TODO refactor this mapping finder into suitable class/module suchg as schemable
    composer_excel_map = {}
    asset.composers.each do |comp|
      col = comp.mappings.detect { |m| m.system_key_field.field == "Column" }
      puts "SET #{comp}"
      puts "TO #{col.value}" if col
      composer_excel_map[comp] = (col.value.to_i) if col
    end

    # Now iterate over all Excel rows and
    # MAP : Composer => data from column
    # TODO ensure even if column empty a nil value stored in map
    # as current simple pattern just expects same no of rows for each Composer
    #
    @excel.each_row do |row|
      composer_excel_map.each do |comp, column|
              puts "ADD DATA #{@excel.value( row, column )}"
        asset.data_store.add(comp, @excel.value( row, column ))
      end
    end
  end


  # TODO - own_sheet should be driven by the TYPE of Composer and number of children
  
  def add_to_excel( composer, own_sheet = true, row = 1, col = 1 )

    if(Config::CONFIG["host_os"] =~ /^win|mswin/i)  # Windows specific code
      puts "export to excel [#{composer.excel?}] - #{composer.inspect}"
      @excel ||= JExcelWin32.new( 1 )

      if composer.excel?
        #store = @excel.active_sheet_index()
        #TODO - implement own sheet - composer.name.nil? ? @excel.add_sheet : @excel.add_sheet  # ( composer.name )

        if( composer.parent )
          row_header = "#{composer.parent.name}::#{composer.name}"
        else
          row_header = composer.name
        end

        #puts "SET CELL", row, col, row_header
        @excel.set_cell(row, col, row_header)

        #@excel.set_active_sheet( store )
        col = (col + 1) unless (own_sheet)
      end

      composer.children.each { |child| col = add_to_excel(child, own_sheet, row, col) }

      return col
    end
  end
  
  # TODO Create new Asset structure for supplied project, based on data from Excel spreadsheet
	
  def import( file, project, asset_name, options = {} )
										
    if( Asset.count(:conditions => ["project_id = ? AND name = ? ", project.id, asset_name]) != 0)
      raise "ERROR - Asset name #{asset_name} provided already in use"
    end
						
    path = options[:path]
						
    xlfile = path.nil? ?  file : File.join( path, file) 
			
    if( ! File.exists? xlfile ) 		#TODO raise
      puts "ERROR - file #{xlfile} not found"
      return
    end
																
    @project = project
			
    @type = BasicType.find_or_create_by_name( :name => 'string', :name_space => 'ADAM' )
			
    puts "Process file #{xlfile}"	

    @asset = Asset.create( :project => @project, :name => asset_name, :version => 1 )
	
    # 1-1 composer with asset - effectively the root node
			
    @composer = ExcelSystem::add_composer( @asset, asset_name)		
						
    excel = ExcelWin32.new(false)
				
    excel.open(xlfile)
				
    excel.set_active_sheet( options[:worksheet] ) if options[:worksheet]
			
    node_options = {:asset_schemas => [:XMLSystem, :ExcelSystem] }
			
    # data range  -> r0, c0, rn, cn,
			
    if options[:components][:column]
				
      components = options[:components][:column] 
      nodes 		 = options[:nodes][:column]
				
      columns = [components, nodes]
							
      data = excel.get_range( 1, columns.min, 200, columns.max)			
	
      puts "EXCEL COLUMN DATA #{data.inspect}"
				
      comp_eval, row_eval = (columns.min == components) ? ["row.first", "row.last"] : ["row.last", "row.first"]

      puts "#{comp_eval} -> #{row_eval}"
								
      data.each do |row|				
        composer = ExcelSystem::find_or_add_composer( @asset, eval(comp_eval), @composer )		# excel index starts at 1 - this is array index 
														
        ##ExcelSystem::add_node( @asset, composer, eval(row_eval), @type, node_options)
      end
				
    else
								
      components = options[:components][:row]
      nodes 		 = options[:nodes][:row]
				
      columns = [components, nodes ]
				
      data = excel.get_range( 1, columns.min, 200, columns.max)		
				
      puts "EXCEL ROW DATA #{data.inspect}"
							
      # Add a new composer to current parent
      ExcelSystem::add_composer( @asset, data[components + 1], @composer )		# excel index starts at 1 - this is array index 
				
      #ExcelSystem::add_node( @asset, @composer, data[nodes + 1], @type, node_options)
									
    end

  end
		
  alias :from_excel :import
                
  #include DynamicMigrations
  
  # TODO - use apache.poi to get data from Excel
  
  #  def to_calypso(asset, file)
  #
  #    @excel = JExcelWin32.new(false)
  #
  #    @excel.open(file)
  #
  #    #excel.visible
  #
  #    composer = asset.root
  #
  #    nsz = composer.excel_nodes.size
  #
  #    composer.descendants.each { |d|
  #      nsz += d.excel_nodes.size
  #    }
  #
  #    data = excel.get_range( 1, 1, 5, nsz)
  #
  #    @excel.workbook.Close(0)
  #
  #    @excel.Quit()
  #
  #    calypso = Calypso.new
  #
  #    calypso.to_xml( asset, data )
  #
  #  end
 
	
end