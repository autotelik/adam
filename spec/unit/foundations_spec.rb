require 'spec_helper'

# TODO - the fixtures we create seem to stick around, not sure how
# to force fixture transactions

def cleanup_transactions
  Project.delete_all
  Asset.delete_all
  Composer.delete_all
end

module Adam

  describe "Projects" do

    # We are not in a Rails project so not so sure about assuming the basics of AR,
    # test some of the basics of the fundamental models

    before(:each) do
      cleanup_transactions
      @project = Project.new(
        :name => 'Example Container',
        :description => 'A test project',
        :identifier => 'testproj')
    end

    it "should be valid" do
      puts "#{@project.errors.full_messages.inspect}" unless(@project.valid?)
      @project.should be_valid
    end

    it "should save" do
      @project.save.should be_true
    end

  end

   describe "Assets" do

    before(:each) do
      cleanup_transactions

      @project = Project.create(
        :name => 'Example Asset Container',
        :description => 'A test asset project',
        :identifier => 'tap')
      puts @project.inspect
      @asset = Asset.new( :name => 'Test Asset', :project => @project)
    end

    it "should be valid" do
      puts "#{@asset.errors.full_messages.inspect}" unless(@asset.valid?)
      @asset.should be_valid
    end

    it "should save" do
      @asset.save.should be_true
    end

  end

  describe "Composers" do

    before(:each) do

      cleanup_transactions
      
      @project = Project.create(
        :name => 'Example Composer Container',
        :description => 'A test composer project',
        :identifier => 'tcp')

      @asset = Asset.create( :name => 'Test Asset', :project => @project)
    end

    it "should be valid" do
      @composer = Composer.new(:name => "Test", :asset => @asset)
      puts "#{@composer.errors.full_messages.inspect}" unless(@composer.valid?)
      @composer.should be_valid
    end

    it "should be valid" do
      @composer = Composer.new(:name => "Test", :asset => @asset)
      @composer.save.should be_true
    end

  end

end
  