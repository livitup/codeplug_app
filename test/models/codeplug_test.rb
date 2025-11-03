require "test_helper"

class CodeplugTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save codeplug with valid attributes" do
    codeplug = build(:codeplug)
    assert codeplug.save, "Failed to save codeplug with valid attributes"
  end

  test "should not save codeplug without user" do
    codeplug = build(:codeplug, user: nil)
    assert_not codeplug.save, "Saved codeplug without user"
    assert_includes codeplug.errors[:user], "must exist"
  end

  test "should not save codeplug without name" do
    codeplug = build(:codeplug, name: nil)
    assert_not codeplug.save, "Saved codeplug without name"
    assert_includes codeplug.errors[:name], "can't be blank"
  end

  test "should save codeplug with empty description" do
    codeplug = build(:codeplug, description: nil)
    assert codeplug.save, "Failed to save codeplug with nil description"
  end

  test "should default public to false" do
    codeplug = build(:codeplug)
    codeplug.save
    assert_equal false, codeplug.public, "public should default to false"
  end

  test "should save codeplug with public true" do
    codeplug = build(:codeplug, public: true)
    assert codeplug.save, "Failed to save codeplug with public true"
    assert_equal true, codeplug.public
  end

  test "should save codeplug with public false" do
    codeplug = build(:codeplug, public: false)
    assert codeplug.save, "Failed to save codeplug with public false"
    assert_equal false, codeplug.public
  end

  # Association Tests
  test "should belong to user" do
    codeplug = build(:codeplug)
    assert_respond_to codeplug, :user
  end

  test "user association should be configured" do
    association = Codeplug.reflect_on_association(:user)
    assert_not_nil association, "user association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should have many zones" do
    codeplug = create(:codeplug)
    assert_respond_to codeplug, :zones
  end

  test "zones association should be configured with dependent destroy" do
    association = Codeplug.reflect_on_association(:zones)
    assert_not_nil association, "zones association should exist"
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
  end

  test "should have many channels" do
    codeplug = create(:codeplug)
    assert_respond_to codeplug, :channels
  end

  test "channels association should be configured with dependent destroy" do
    association = Codeplug.reflect_on_association(:channels)
    assert_not_nil association, "channels association should exist"
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
  end

  # Dependent Destroy Tests
  test "destroying codeplug should destroy associated zones" do
    codeplug = create(:codeplug)
    # Note: Zones will be created in a later issue, so this test will fail until then
    # For now, we're just testing the association configuration exists
    skip "Zone model not yet implemented"
  end

  test "destroying codeplug should destroy associated channels" do
    codeplug = create(:codeplug)
    # Note: Channels will be created in a later issue, so this test will fail until then
    # For now, we're just testing the association configuration exists
    skip "Channel model not yet implemented"
  end

  # Attribute Tests
  test "should store name as string" do
    codeplug = create(:codeplug, name: "My Radio Config")
    assert_equal "My Radio Config", codeplug.name
  end

  test "should store description as text" do
    long_description = "A" * 500
    codeplug = create(:codeplug, description: long_description)
    assert_equal long_description, codeplug.description
  end

  # Multiple Codeplugs per User
  test "user can have multiple codeplugs" do
    user = create(:user)
    codeplug1 = create(:codeplug, user: user, name: "Config 1")
    codeplug2 = create(:codeplug, user: user, name: "Config 2")

    assert_equal 2, user.codeplugs.count
    assert_includes user.codeplugs, codeplug1
    assert_includes user.codeplugs, codeplug2
  end

  test "different users can have codeplugs with same name" do
    user1 = create(:user)
    user2 = create(:user)
    codeplug1 = create(:codeplug, user: user1, name: "My Config")
    codeplug2 = create(:codeplug, user: user2, name: "My Config")

    assert codeplug1.persisted?
    assert codeplug2.persisted?
  end
end
