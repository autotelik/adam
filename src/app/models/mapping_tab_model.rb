class MappingTabModel

  attr_accessor :mapping_source, :reference, :current_asset

  def initialize
  end

  def systems
    System.find( :all )
  end
  
  def create( reference )
    return unless @current_asset
    @current_asset.mapping_schemas.create(:reference => reference, :source => @mapping_source)
  end


end
