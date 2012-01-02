module ArJdbc
  def self.discover_extensions
    if defined?(::Gem) && ::Gem.respond_to?(:find_files)
      files = ::Gem.find_files('arjdbc/discover')
    else
      files = $LOAD_PATH.map do |p|
        discover = File.join(p, 'arjdbc','discover.rb')
        File.exist?(discover) ? discover : nil  # TOM CHANGE - BUG used to be File.exist?(p) -TODO - Patch ?
      end.compact
    end
    files.each do |f|
      puts "Loading #{f}" if $DEBUG
      require f
    end
  end

  discover_extensions
end
