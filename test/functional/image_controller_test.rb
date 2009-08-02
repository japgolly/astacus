require 'test_helper'

class ImageControllerTest < ActionController::TestCase

  context "When sending a JPEG" do
    setup do
      @img= images(:in_absentia)
      get :view, :id => @img.id
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
    end
  end

  context "When sending a PNG" do
    setup do
      @img= images(:ponk)
      get :view, :id => @img.id
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
    end
  end

  context "When trying to send a non-existant file" do
    setup do
      get :view, :id => -1
    end
    should_respond_with :not_found
  end
end
