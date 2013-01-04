module Neurogami
  module SwingSet

    # :stopdoc:
    VERSION = '0.3.0'
    LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
    PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
    # :startdoc:

    # Returns the version string for the library.
    #
    def self.version
      VERSION
    end

    # Returns the library path for the module. If any arguments are given,
    # they will be joined to the end of the libray path using
    # <tt>File.join</tt>.
    #
    def self.libpath *args 
      args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
    end

    # Returns the lpath for the module. If any arguments are given,
    # they will be joined to the end of the path using
    # <tt>File.join</tt>.
    #
    def self.path *args 
      args.empty? ? PATH : ::File.join(PATH, args.flatten)
    end

    # Utility method used to rquire all files ending in .rb that lie in the
    # directory below this file that has the same name as the filename passed
    # in. Optionally, a specific _directory_ name can be passed in such that
    # the _filename_ does not have to be equivalent to the directory.
    #
    def self.require_all_libs_relative_to fname, dir = nil 
      dir ||= ::File.basename(fname, '.*')
      search_me = ::File.expand_path( ::File.join(::File.dirname(fname), dir, '**', '*.rb'))
      Dir.glob(search_me).sort.each {|rb| require rb}
    end


    def self.find_mig_jar glob_path
      Dir.glob(glob_path).select { |f| 
        f =~ /(miglayout-)(.+).jar$/}.first
    end

    def self.copy_over_mig path = 'lib/java'
      require 'fileutils'

      java_lib_dir = File.join File.dirname( File.expand_path(__FILE__) ),  'java'
      mig_jar = find_mig_jar "#{java_lib_dir}/*.jar"

      raise "Failed to find MiG layout jar to copy over from '#{java_lib_dir}'!" unless mig_jar 

      if File.exist? "#{path}/#{mig_jar}"
        warn "It seems that the miglayout jar file already exists. Remove it or rename it, and try again."
        exit
      end

      FileUtils.mkdir_p path unless File.exists? path
      warn "Have mig jar at #{mig_jar}"
      FileUtils.cp_r mig_jar, path, :verbose =>  true
    end

    def self.copy_over
      copy_over_ruby
      copy_over_mig
    end

    def self.copy_over_ruby path = 'lib/ruby'
      require 'fileutils'
      
      here = File.dirname(File.expand_path(__FILE__))

      if File.exist?("#{path}/swingset.rb") || File.exist?("#{path}/swingset")
        warn "It seems that the swingset files already exist. Remove or rename them, and try again."
        exit
      end
      
      FileUtils.mkdir_p path unless File.exists? path
      FileUtils.cp_r "#{here}/swingset", path, :verbose =>  true
      FileUtils.cp_r "#{here}/swingset.rb", path, :verbose =>  true
      FileUtils.cp_r "#{here}/swingset_utils.rb", path, :verbose =>  true
    end

  end  # module Swingset
end


# EOF

if $0 == __FILE__
  java_lib_dir = File.join File.dirname( File.expand_path(__FILE__) ),  'java'
  warn  java_lib_dir
  warn Neurogami::SwingSet.find_mig_jar "#{java_lib_dir}/*.jar"

end
