require "test_helper"

class NetworkTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save network with valid attributes" do
    network = build(:network)
    assert network.save, "Failed to save network with valid attributes"
  end

  test "should not save network without name" do
    network = build(:network, name: nil)
    assert_not network.save, "Saved network without name"
    assert_includes network.errors[:name], "can't be blank"
  end

  test "should not save network with duplicate name" do
    existing_network = create(:network, name: "Brandmeister")
    duplicate_network = build(:network, name: "Brandmeister")
    assert_not duplicate_network.save, "Saved network with duplicate name"
    assert_includes duplicate_network.errors[:name], "has already been taken"
  end

  test "should save network with unique name" do
    create(:network, name: "Brandmeister")
    network = build(:network, name: "DMRVA")
    assert network.save, "Failed to save network with unique name"
  end

  # Attribute Tests
  test "should save network with description" do
    network = build(:network, description: "Global DMR network")
    assert network.save, "Failed to save network with description"
  end

  test "should save network with website" do
    network = build(:network, website: "https://brandmeister.network")
    assert network.save, "Failed to save network with website"
  end

  test "should save network with network_type Analog" do
    network = build(:network, network_type: "Analog")
    assert network.save, "Failed to save network with Analog network_type"
    assert_equal "Analog", network.network_type
  end

  test "should save network with network_type Digital-DMR" do
    network = build(:network, network_type: "Digital-DMR")
    assert network.save, "Failed to save network with Digital-DMR network_type"
    assert_equal "Digital-DMR", network.network_type
  end

  test "should save network with network_type Digital-P25" do
    network = build(:network, network_type: "Digital-P25")
    assert network.save, "Failed to save network with Digital-P25 network_type"
    assert_equal "Digital-P25", network.network_type
  end

  test "should not save network with invalid network_type" do
    network = build(:network, network_type: "invalid_type")
    assert_not network.save, "Saved network with invalid network_type"
    assert_includes network.errors[:network_type], "invalid_type is not a valid network type"
  end

  test "should allow nil description" do
    network = build(:network, description: nil)
    assert network.save, "Failed to save network with nil description"
  end

  test "should allow nil website" do
    network = build(:network, website: nil)
    assert network.save, "Failed to save network with nil website"
  end

  test "should not save network without network_type" do
    network = build(:network, network_type: nil)
    assert_not network.save, "Saved network without network_type"
    assert_includes network.errors[:network_type], "can't be blank"
  end

  # Website URL Validation Tests
  test "should save network with valid http URL" do
    network = build(:network, website: "http://example.com")
    assert network.save, "Failed to save network with valid http URL"
  end

  test "should save network with valid https URL" do
    network = build(:network, website: "https://example.com")
    assert network.save, "Failed to save network with valid https URL"
  end

  test "should not save network with invalid URL format" do
    network = build(:network, website: "not-a-url")
    assert_not network.save, "Saved network with invalid URL format"
    assert_includes network.errors[:website], "must be a valid HTTP or HTTPS URL"
  end

  test "should not save network with javascript protocol URL" do
    network = build(:network, website: "javascript:alert('xss')")
    assert_not network.save, "Saved network with javascript protocol URL"
    assert_includes network.errors[:website], "must be a valid HTTP or HTTPS URL"
  end

  test "should allow blank website" do
    network = build(:network, website: "")
    assert network.save, "Failed to save network with blank website"
  end

  # Association Tests
  # TODO: Uncomment when TalkGroup model is implemented
  # test "should respond to talkgroups association" do
  #   network = build(:network)
  #   assert_respond_to network, :talkgroups
  # end

  # test "talkgroups association should be configured" do
  #   association = Network.reflect_on_association(:talkgroups)
  #   assert_not_nil association, "talkgroups association should exist"
  #   assert_equal :has_many, association.macro
  # end

  # TODO: Uncomment when SystemNetwork join model is implemented
  # test "should respond to system_networks association" do
  #   network = build(:network)
  #   assert_respond_to network, :system_networks
  # end

  # test "should respond to systems association" do
  #   network = build(:network)
  #   assert_respond_to network, :systems
  # end

  # test "systems association should be through system_networks" do
  #   association = Network.reflect_on_association(:systems)
  #   assert_not_nil association, "systems association should exist"
  #   assert_equal :has_many, association.macro
  #   assert_equal :system_networks, association.options[:through]
  # end

  # Case Sensitivity Tests
  test "name uniqueness should be case insensitive" do
    create(:network, name: "Brandmeister")
    duplicate_network = build(:network, name: "BRANDMEISTER")
    assert_not duplicate_network.save, "Saved network with case-insensitive duplicate name"
  end

  test "should save network with mixed case name if no exact match exists" do
    create(:network, name: "brandmeister")
    network = build(:network, name: "BrandMeister")
    assert_not network.save, "Should not allow case variations of existing names"
  end
end
