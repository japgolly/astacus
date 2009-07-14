require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  should_validate_presence_of :label
  should_validate_presence_of :dir
  should_have_readonly_attributes :dir

  context "Locations" do
    should "have unique dirs" do
      assert_difference 'Location.count' do
        Location.create(:label => 'asd', :dir => File.dirname(__FILE__))
      end
      assert_no_difference 'Location.count' do
        Location.create(:label => 'omg', :dir => File.dirname(__FILE__))
      end
    end

    should "use canonical pathnames" do
      dir= File.join(File.dirname(__FILE__),".",".",".")
      Location.create(:label => 'asd', :dir => dir)
      assert_equal File.expand_path(dir), Location.last.dir
    end

    if RUBY_PLATFORM =~ /cygwin/i
      should "translate windows paths into cygwin paths" do
      Location.create(:label => 'asd', :dir => "c:\\blah\\")
      assert_match %r!^(/cygdrive)?/c/blah$!, Location.last.dir
      end
    end
  end
end
