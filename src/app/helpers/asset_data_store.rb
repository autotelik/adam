# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
# Store actual data against an Asset's structure, for creating populated output and conversions

# TODO - Create iterator directly over @value_map

class AssetDataStore 

  attr_accessor :value_map
  
  def initialize( asset )
    raise TypeError, "Can only store data for object of type Asset" unless asset.is_a?(Asset)
    @asset_id = asset.id
    @value_map = {}
  end

  def clear()
    @value_map = {}
  end

  def add(composer, value)
    @value_map[composer.id] ||= []
    @value_map[composer.id] << value
  end

  # Assume same size array for each key
  
  def data_size
    puts @value_map.values.flatten.size
    (@value_map.values.flatten.size / @value_map.size)
  end

  def size
    @value_map.size
  end

end
