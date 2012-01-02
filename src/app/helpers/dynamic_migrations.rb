require 'rexml/document'

#xml = REXML::Document.new( File.new("W:\\DEV\\Calypso\\SCHEMAS\\calypso-legalentity.xsd") )
#xml = REXML::Document.new( File.new("W:\\DEV\\Calypso\\SCHEMAS\\calypso-base.xsd") )

module DynamicMigrations
  
  module ClassMethods
		
    # Try to create mappings from existing XML
    # Each xpath is taken to be the mapping xpath, and the leaf node and it's parent
    # used to try to find corresponding Composers in the vocab
	 
    def logger
      RAILS_DEFAULT_LOGGER
    end
							
    def find_or_add_composer( asset, name, parent = nil  )
	  	
      child = Composer.find( :first, :conditions => ["name = ? and asset_id = ?", name, asset.id] )
										  	
      if(child.nil?)
        return add_composer(asset, name, parent) 
      else
        return child
      end
    end

    
    # Add a new Composer, and optionally add to a parent
    # Can optionally set it's output views and properties via :
    #           options[:class]   
    #		options[:asset_schemas]
    #		options[:properties]
    #
    def add_composer( asset, name, parent = nil, options = {}  )
      if( options[:type])
        child = options[:type].new(:name => name, :asset => asset)
      else
        child = Composer.new(:name => name, :asset => asset)
      end
      
      child.save
      if parent
        #child = parent.children.create(:asset_id => asset.id, :name => name)
        child.move_to_child_of parent    
      end
      
      if( child.errors.size == 0 )
        # Add output view settings
        if( options[:asset_schemas] )
          [*options[:asset_schemas]].each do |sys|
            AssetSchema.create( :system => System.find_by_type(sys.to_s), :viewable => node)
          end
        end

        opts = options[:properties]

        p = Property.create( opts.merge(:element => node) )	if( opts )

      else
        puts "ERRORS !!!"
        node.errors.each_full {|msg| puts msg}
        node.errors.each_full {|msg| logger.error msg}
        logger.error "Node #{node} - failed to save"
      end

      child
    end
		  			
    # Set output view scheams for the supplied Composer and associated nodes
		
    # Args : system - an output view object, or symbol to such a view, e.g. either 
    #						System.find_by_type( 'ExcelSystem' )  or	
    #						:ExcelSystem 
    #        composer - the top level, parent composer
    #				 children - list of nodes either :
    #				 		[] of composer leaf nodes  e.g. columns = ['issueDate','datedDate','maturityDate']
    #				 		{} of child composers and their leaf nodes e.g. columns = { 'faceValue' => ['quantity', 'currency'] }
		
    def add_asset_all_schema( system, composer)
      system = System.find_by_type( system.to_s ) if system.class == Symbol
			
      composer.asset_schema.create( :system => system, :viewable => lf) unless lf.nil?
      			
      composer.children.each do |c|
        add_asset_all_schema( system, c)
      end
    end
		
    def add_asset_schema( system, composer, children)
			
      system = System.find_by_type( system.to_s ) if system.class == Symbol

      if( children.is_a? Array )
				
        children.each do |node|
          AssetSchema.create( :system => system, :viewable => node)
        end
				
      elsif( children.is_a? Hash )
			
        # map of comp -> node name(s)
				
        children.each do |c,ln|
				
          comp = Composer.find_all_by_name_and_parent_id( c, composer.id)
					
          comp.each { |cp| 
						
            find_nodes = [*ln]		# handles array of nodes or single node
						
            find_nodes.each { |n|
              node = cp.children.detect { |nd| nd.name == n }
              if node
                AssetSchema.create( :system => system, :viewable => node)
              else
                puts "WARNING - No such association #{c} => #{n}"						
              end
            }
          }
        end
      end
    end

  end
	
  def self.included(base)    
    base.extend(ClassMethods)  
  end
		
end