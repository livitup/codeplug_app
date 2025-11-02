require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login form" do
    get login_path
    assert_response :success
    assert_select "form[action=?]", login_path
    assert_select "input[name='email']"
    assert_select "input[name='password']"
  end

  test "should create session with valid credentials" do
    user = create(:user, email: "test@example.com", password: "password123")

    post login_path, params: {
      email: "test@example.com",
      password: "password123"
    }

    assert_redirected_to radio_models_path
    assert_equal "Logged in successfully!", flash[:notice]
    assert_equal user.id, session[:user_id]
  end

  test "should handle case-insensitive email login" do
    user = create(:user, email: "test@example.com", password: "password123")

    post login_path, params: {
      email: "TEST@EXAMPLE.COM",
      password: "password123"
    }

    assert_redirected_to radio_models_path
    assert_equal user.id, session[:user_id]
  end

  test "should not create session with invalid email" do
    post login_path, params: {
      email: "nonexistent@example.com",
      password: "password123"
    }

    assert_response :unprocessable_entity
    assert_select "div.alert", /Invalid email or password/i
    assert_nil session[:user_id]
  end

  test "should not create session with invalid password" do
    create(:user, email: "test@example.com", password: "password123")

    post login_path, params: {
      email: "test@example.com",
      password: "wrongpassword"
    }

    assert_response :unprocessable_entity
    assert_select "div.alert", /Invalid email or password/i
    assert_nil session[:user_id]
  end

  test "should destroy session on logout" do
    user = create(:user)
    post login_path, params: {
      email: user.email,
      password: "password123"
    }
    assert session[:user_id].present?

    delete logout_path
    assert_redirected_to root_path
    assert_equal "Logged out successfully!", flash[:notice]
    assert_nil session[:user_id]
  end

  test "should redirect logged-in user from login page to radio models" do
    user = create(:user)
    post login_path, params: {
      email: user.email,
      password: "password123"
    }

    get login_path
    assert_redirected_to radio_models_path
  end
end
