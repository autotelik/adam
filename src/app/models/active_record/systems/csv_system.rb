# Take a CSV file and create an ADAM asset where
# Asset Name is either passed in as an option, or the file name is used
# Each column in the csv is a leaf node of the asset
require 'system'
require 'csv'


class CsvSystem < System
  
  # Create output for this Asset in CSV format
  #
  def spawn(asset, options = {})
    
    puts "spawn calypso output"
    
    format = options[:seperator] || ','
    
    puts "spawn csv output"
    
    csv = String.new

    csv << asset.name << seperator
    
    add( csv, asset.root )
    csv
  end
  
  def add( csv, composer )
    
    nsz = composer.csv_nodes.size
  
    if nsz > 0 and composer.name and composer.name.size > 0
      xml.tag!( composer.name.gsub(/\s/, "_") ) do
        composer.leaf_nodes.each do |ln| 
          xml.tag!( ln.name, "dummy" ) if( ln.calypso? == true)
        end
        composer.children.each { |child| add(xml, child) }
      end
    else
      composer.leaf_nodes.each do |ln|  
        xml.tag!( ln.name, "dummy" ) if( ln.calypso? == true)
      end
      composer.children.each { |child| add(xml, child) }
    end  
  end
  
  def transform( input, options = {})
    format = options[:render]
    if format == :excel
      
    end
  end
  
  def from_csv( project, file, options = {} )
		
    @project = project
		
    path = options[:path]
		
    csvfile = path.nil? ?  file : File.join( path, file) 
		
    if( ! File.exists? csvfile ) 		#TODO raise
      puts "ERROR - file #{csvfile} not found"
      return
    end
		
    puts "Process file #{csvfile}"
		
    # Get headings only
		
    headings = String.new
				
    File.open(csvfile) do |f|
      headings = f.gets
    end
		
    puts "HEADINGS #{headings}"
		
    asset = options[:asset] || File.basename( csvfile, ".csv" )
		
    return if Asset.find_by_name(asset)
							
    @temp = Asset.create( :project => @project, :name => asset, :version => 1 )

    # 1-1 composer with asset - effectively the root node

    @composer = DynamicMigrations::add_composer( @temp, asset, asset, 1 )		
																
    CSV::parse(headings) do |row|
      row.each { |item|  
        puts "COLUMN [#{item}]"
        node = Composer.create( :asset => @temp, :name => item)
        
        if node.valid?
          node.save
          # Add XMLSystem output view
												 
          AssetSchema.create( :system => System.find_by_type('XMLSystem'), :leaf_node => node)	
        else
          node.errors.each_full {|msg| p msg}
          puts "Node #{item} - failed to save"
        end
					
      }					
    end
  end
	
  alias :from :from_csv
		
end