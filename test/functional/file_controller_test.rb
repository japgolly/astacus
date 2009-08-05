require 'test_helper'
require 'stringio'

class FileControllerTest < ActionController::TestCase

  context "file/image" do

    context "when sending a JPEG" do
      setup do
        @img= images(:in_absentia)
        get :image, :id => @img.id
      end
      should_respond_with :success
      should "send the pic" do
        assert_equal @img.data, response.body
      end
      should "set the response headers correctly" do
        h= response.header
        assert_equal 'image/jpeg', h['Content-Type']
        assert_equal @img.size.to_s, h['Content-Length'].to_s
        assert_equal %!inline; filename="#{@img.id}.jpg"!, h['Content-Disposition']
        assert_equal 'binary', h['Content-Transfer-Encoding']
      end
    end

    context "when sending a PNG" do
      setup do
        @img= images(:ponk)
        get :image, :id => @img.id
      end
      should_respond_with :success
      should "send the pic" do
        assert_equal @img.data, response.body
      end
      should "set the response headers correctly" do
        h= response.header
        assert_equal 'image/png', h['Content-Type']
        assert_equal @img.size.to_s, h['Content-Length'].to_s
        assert_equal %!inline; filename="#{@img.id}.png"!, h['Content-Disposition']
        assert_equal 'binary', h['Content-Transfer-Encoding']
      end
    end

    context "when given a bad id param" do
      setup do
        get :image, :id => -1
      end
      should_respond_with :not_found
    end
  end # Context: file/image

  context "file/audio" do
    context "when sending a valid file" do
      setup do
        @af= audio_files(:silsila_ye_chaahat_ka)
        assert @af.exists?, "#{@af.filename} doesn't exist."
        @mp3_content= File.read(@af.filename)
        get :audio, :id => @af.id
      end
      should_respond_with :success
      should "send the file" do
        output= StringIO.new
        output.binmode
        assert_nothing_raised { response.body.call(response, output) }
        assert_equal @mp3_content, output.string
      end
      should "set the response headers correctly" do
        h= response.header
        assert_equal 'audio/mpeg', h['Content-Type']
        assert_equal @mp3_content.size.to_s, h['Content-Length'].to_s
        assert_equal %!attachment; filename="#{@af.basename}"!, h['Content-Disposition']
        assert_equal 'binary', h['Content-Transfer-Encoding']
      end
    end

    context "when the file doesnt exist anymore" do
      setup do
        @af= audio_files(:the_sound_of_muzak)
        assert !@af.exists?
        get :audio, :id => @af
      end
      should_respond_with 417
      should "tell the user the file doesnt exist" do
        assert_template 'audio_file_not_found'
        assert_response_includes @af.filename
      end
    end

    context "when given a bad id param" do
      setup do
        get :audio, :id => -1
      end
      should_respond_with :not_found
    end
  end # Context: file/image
end
