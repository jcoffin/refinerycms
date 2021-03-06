require 'spec_helper'

describe Resource do

  def reset_resource(options = {})
    @valid_attributes = {
      :id => 1,
      :file => File.new(File.expand_path('../../uploads/refinery_is_awesome.txt', __FILE__))
    }.merge(options)

    @resource.destroy if @resource
    @resource = Resource.create!(@valid_attributes)
  end

  def resource_can_be_destroyed
    @resource.destroy.should == true
  end

  before(:each) do
    reset_resource
  end

  # clean up after ourselves.
  after(:each) do
    Resource.destroy_all
  end

  context "with valid attributes" do
    it "should create successfully" do
      @resource.errors.empty?
    end
  end

  context "resource url" do
    it "should respond to .url" do
      @resource.respond_to?(:url).should == true
    end

    it "should not support thumbnailing like images do" do
      @resource.respond_to?(:thumbnail).should == false
    end

    it "should contain its filename at the end" do
      @resource.url.split('/').last.should == @resource.file_name
    end
  end

  describe "#type_of_content" do
    it "returns formated mime type" do
      @resource.type_of_content.should == "text plain"
    end
  end

  describe "#title" do
    it "returns a titleized version of the filename" do
      @resource.title.should == "Refinery Is Awesome"
    end
  end

  describe ".per_page" do
    context "dialog is true" do
      it "returns resource count specified by PAGES_PER_DIALOG constant" do
        Resource.per_page(true).should == Resource::PAGES_PER_DIALOG
      end
    end

    context "dialog is false" do
      it "returns resource count specified by PAGES_PER_ADMIN_INDEX constant" do
        Resource.per_page.should == Resource::PAGES_PER_ADMIN_INDEX
      end
    end
  end

  describe ".create_resources" do
    let(:file) { File.new(File.expand_path('../../uploads/refinery_is_awesome.txt', __FILE__)) }

    context "only one resource uploaded" do
      it "returns an array containing one resource" do
        Resource.create_resources(:file => file).should have(1).item
      end
    end

    context "many resources uploaded at once" do
      it "returns an array containing all those resources" do
        Resource.create_resources(:file => [file, file, file]).should have(3).items
      end
    end

    specify "each returned array item should be an instance of resource" do
      Resource.create_resources(:file => [file, file, file]).each do |resource|
        resource.should be_an_instance_of(Resource)
      end
    end
  end

end
