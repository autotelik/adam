# THE XML SYSTEM CLASS
# 
# TODO - Benchmark REXML and hpricot  - probably move to hpicrot

require 'rexml/document'
require 'read_from_base'

class ReadFromXML < ReadFromBase

  # TODO - This is broken

  def from_xml( project, xml  )

    @project = project
    
    xpaths = []

    xml.each_recursive do |e|
      # reduce repeating structure definitions like Value[0] to Value
      xp = e.xpath.gsub(/\[\d+\]/, '')
      xpaths << xp unless(xp.empty? or xp.nil?)
    end

    xpaths.uniq.each do |x|

      puts "XPATH #{x}"

      # TODO - Look down xpath split on '/' and then find Composer based on the elements
      elements = x.split(/\//)
      elements.shift  if elements.first.empty?

      puts "elements #{elements.inspect}"

      parent = find_or_create_asset_and_root( elements.shift )

      elements.each do |node|
        puts "NODE #{node}"
        puts node.class
        parent = ReadFromXML.add_composer( asset, node, parent)
      end
    end
  end
end