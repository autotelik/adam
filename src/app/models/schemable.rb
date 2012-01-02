# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
require 'string'
require 'system'
require 'active_support/inflector'

# Eager load all system model classes or the STI mechanism used in System table will break down

matcher = /\A#{Regexp.escape(ADAM_SRC_PATH)}(.*)\.rb\Z/
Dir.glob("#{ADAM_SRC_PATH}/models/*_system.rb").sort.each do |file|
  require file.sub(matcher, '\1')
end

module Schemable
 
  def self.included(klazz)  # klazz is that class object that @included this module
    klazz.class_eval do
      has_many   :asset_schemas, :as => :viewable, :dependent => :destroy
      has_many   :systems, :through => :asset_schemas
    end
  end
  
  # HELPERS
   
  # The list of System classes  (class name convention = XxxSystem)
  
  def self.all_schemas(reload = false)
    @@all_systems = nil if reload
    @@all_systems ||= System.find :all
    @@all_systems
  end
  
  def self.schema_names( reload = false)
    all_schemas(reload).collect{|s| schema_name(s) }
  end

  def self.schema_name( system )
    "#{system.class.name.sub('System','')}"
  end

  # Collection of method names, for determining whether a node supports
  # a particular schema (through system) e.g :xml?, :csv?, :excel?, :calypso? etc

  def self.schema_method(system)
    "#{ActiveSupport::Inflector::underscore(schema_name(system))}?"
  end

  def self.schema_methods( reload = false)
    all_schemas(reload).collect{|s| "#{schema_method(s)}?".intern }
  end


  # Now mixin the actual methods, for determining whether a node supports
  # a particular schema (through system) e.g. composer.excel? or node.xml? or schema.calypso_api?
    
  all_schemas(true).each do |klass|
    classevalstr=<<-EOF
      def #{schema_method(klass)}
        systems.any? {|s| s.is_a? #{klass.class} }
      end
    EOF
    #DEBUG puts classevalstr
    class_eval classevalstr
  end

end