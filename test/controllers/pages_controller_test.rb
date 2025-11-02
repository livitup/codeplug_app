require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_path
    assert_response :success
    assert_select "h1", /Welcome/i
  end

  test "should get help" do
    get help_path
    assert_response :success
    assert_select "h1", /Help/i
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "h1", /About/i
  end

  test "pages should be accessible without authentication" do
    # All pages should be accessible without logging in
    get root_path
    assert_response :success

    get help_path
    assert_response :success

    get about_path
    assert_response :success
  end
end
