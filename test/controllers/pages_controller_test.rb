require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home landing page when not logged in" do
    get root_path
    assert_response :success
    assert_select "h1", /Welcome/i
  end

  test "should get dashboard when logged in" do
    user = create(:user)
    log_in_as(user)

    get root_path
    assert_response :success
    assert_select "h1", /Dashboard/i
  end

  test "dashboard shows user stats" do
    user = create(:user)
    create_list(:codeplug, 2, user: user)
    create_list(:zone, 3, user: user)
    log_in_as(user)

    get root_path
    assert_response :success
    # Check that stats are present
    assert_select ".display-4", minimum: 3
  end

  test "dashboard shows recent codeplugs" do
    user = create(:user)
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")
    log_in_as(user)

    get root_path
    assert_response :success
    assert_select "a", text: /Test Codeplug/
  end

  test "dashboard shows recent zones" do
    user = create(:user)
    zone = create(:zone, user: user, name: "Test Zone")
    log_in_as(user)

    get root_path
    assert_response :success
    assert_select "a", text: /Test Zone/
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
