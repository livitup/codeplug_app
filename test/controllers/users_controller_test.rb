require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # Registration Tests
  test "should get new registration form" do
    get new_user_path
    assert_response :success
    assert_select "form[action=?]", users_path
  end

  test "should create user with valid data" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          name: "New User"
        }
      }
    end
    assert_redirected_to radio_models_path
    assert_equal "Account created successfully!", flash[:notice]
    assert session[:user_id].present?, "User should be logged in after registration"
  end

  test "should not create user with invalid email" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          email: "invalid-email",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select "div.alert", /error/i
  end

  test "should not create user with mismatched passwords" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          email: "test@example.com",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create user with duplicate email" do
    create(:user, email: "existing@example.com")
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          email: "existing@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Profile Management Tests
  test "should show profile when logged in" do
    user = create(:user)
    log_in_as(user)

    get user_path(user)
    assert_response :success
    assert_select "h1", /profile/i
    assert_select "p", /#{user.email}/i
  end

  test "should redirect to login when accessing profile not logged in" do
    user = create(:user)
    get user_path(user)
    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page.", flash[:alert]
  end

  test "should get edit profile form when logged in" do
    user = create(:user)
    log_in_as(user)

    get edit_user_path(user)
    assert_response :success
    assert_select "form[action=?]", user_path(user)
  end

  test "should redirect to login when accessing edit profile not logged in" do
    user = create(:user)
    get edit_user_path(user)
    assert_redirected_to login_path
  end

  test "should update profile with valid data" do
    user = create(:user)
    log_in_as(user)

    patch user_path(user), params: {
      user: {
        name: "Updated Name",
        callsign: "W1ABC",
        default_power_level: "High"
      }
    }
    assert_redirected_to user_path(user)
    assert_equal "Profile updated successfully!", flash[:notice]

    user.reload
    assert_equal "Updated Name", user.name
    assert_equal "W1ABC", user.callsign
    assert_equal "High", user.default_power_level
  end

  test "should not update profile with invalid email" do
    user = create(:user, email: "original@example.com")
    log_in_as(user)

    patch user_path(user), params: {
      user: { email: "invalid-email" }
    }
    assert_response :unprocessable_entity

    user.reload
    assert_equal "original@example.com", user.email
  end

  test "should not allow user to edit another user's profile" do
    user1 = create(:user)
    user2 = create(:user)
    log_in_as(user1)

    get edit_user_path(user2)
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should not allow user to update another user's profile" do
    user1 = create(:user)
    user2 = create(:user, name: "Original Name")
    log_in_as(user1)

    patch user_path(user2), params: {
      user: { name: "Hacked Name" }
    }
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]

    user2.reload
    assert_equal "Original Name", user2.name
  end
end
