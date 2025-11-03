require "test_helper"

class SystemNetworkTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save system_network with valid attributes" do
    system_network = build(:system_network)
    assert system_network.save, "Failed to save system_network with valid attributes"
  end

  test "should not save system_network without system" do
    system_network = build(:system_network, system: nil)
    assert_not system_network.save, "Saved system_network without system"
    assert_includes system_network.errors[:system], "must exist"
  end

  test "should not save system_network without network" do
    system_network = build(:system_network, network: nil)
    assert_not system_network.save, "Saved system_network without network"
    assert_includes system_network.errors[:network], "must exist"
  end

  # Uniqueness Tests
  test "should not save system_network with duplicate system and network combination" do
    system = create(:system)
    network = create(:network)
    create(:system_network, system: system, network: network)

    duplicate = build(:system_network, system: system, network: network)
    assert_not duplicate.save, "Saved system_network with duplicate system/network combination"
    assert_includes duplicate.errors[:system_id], "has already been taken"
  end

  test "should save system_network with same system but different network" do
    system = create(:system)
    network1 = create(:network, name: "Network 1")
    network2 = create(:network, name: "Network 2")

    create(:system_network, system: system, network: network1)
    system_network2 = build(:system_network, system: system, network: network2)

    assert system_network2.save, "Failed to save system_network with same system but different network"
  end

  test "should save system_network with same network but different system" do
    system1 = create(:system, name: "System 1")
    system2 = create(:system, name: "System 2")
    network = create(:network)

    create(:system_network, system: system1, network: network)
    system_network2 = build(:system_network, system: system2, network: network)

    assert system_network2.save, "Failed to save system_network with same network but different system"
  end

  # Association Tests
  test "should belong to system" do
    system_network = build(:system_network)
    assert_respond_to system_network, :system
  end

  test "should belong to network" do
    system_network = build(:system_network)
    assert_respond_to system_network, :network
  end

  test "system association should be configured" do
    association = SystemNetwork.reflect_on_association(:system)
    assert_not_nil association, "system association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "network association should be configured" do
    association = SystemNetwork.reflect_on_association(:network)
    assert_not_nil association, "network association should exist"
    assert_equal :belongs_to, association.macro
  end
end
