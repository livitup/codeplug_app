require "test_helper"

class ZoneTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save zone with valid attributes" do
    zone = build(:zone)
    assert zone.save, "Failed to save zone with valid attributes"
  end

  test "should save zone without codeplug (codeplug is now optional)" do
    zone = build(:zone, codeplug: nil)
    assert zone.save, "Failed to save zone without codeplug"
  end

  test "should not save zone without user" do
    zone = build(:zone, user: nil)
    assert_not zone.save, "Saved zone without user"
    assert_includes zone.errors[:user], "must exist"
  end

  test "should not save zone without name" do
    zone = build(:zone, name: nil)
    assert_not zone.save, "Saved zone without name"
    assert_includes zone.errors[:name], "can't be blank"
  end

  test "should save zone with empty long_name" do
    zone = build(:zone, long_name: nil)
    assert zone.save, "Failed to save zone with nil long_name"
  end

  test "should save zone with empty short_name" do
    zone = build(:zone, short_name: nil)
    assert zone.save, "Failed to save zone with nil short_name"
  end

  # Association Tests
  test "should belong to codeplug" do
    zone = build(:zone)
    assert_respond_to zone, :codeplug
  end

  test "codeplug association should be configured" do
    association = Zone.reflect_on_association(:codeplug)
    assert_not_nil association, "codeplug association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should have many channel_zones" do
    zone = create(:zone)
    assert_respond_to zone, :channel_zones
  end

  test "channel_zones association should be configured with dependent destroy" do
    association = Zone.reflect_on_association(:channel_zones)
    assert_not_nil association, "channel_zones association should exist"
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
  end

  test "should have many channels through channel_zones" do
    zone = create(:zone)
    assert_respond_to zone, :channels
  end

  test "channels association should be configured as through" do
    association = Zone.reflect_on_association(:channels)
    assert_not_nil association, "channels association should exist"
    assert_equal :has_many, association.macro
    assert_equal :channel_zones, association.options[:through]
  end

  # Dependent Destroy Tests
  test "destroying zone should destroy associated channel_zones" do
    zone = create(:zone)
    # Note: ChannelZone will be created in a later issue, so this test will fail until then
    # For now, we're just testing the association configuration exists
    skip "ChannelZone model not yet implemented"
  end

  # Attribute Tests
  test "should store name as string" do
    zone = create(:zone, name: "Repeaters")
    assert_equal "Repeaters", zone.name
  end

  test "should store long_name as string" do
    zone = create(:zone, long_name: "Local Repeaters Zone")
    assert_equal "Local Repeaters Zone", zone.long_name
  end

  test "should store short_name as string" do
    zone = create(:zone, short_name: "RPT")
    assert_equal "RPT", zone.short_name
  end

  test "should allow different zones with same name in different codeplugs" do
    codeplug1 = create(:codeplug)
    codeplug2 = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug1, name: "Zone A")
    zone2 = create(:zone, codeplug: codeplug2, name: "Zone A")

    assert zone1.persisted?
    assert zone2.persisted?
  end

  # Multiple Zones per Codeplug
  test "codeplug can have multiple zones" do
    codeplug = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug, name: "Zone 1")
    zone2 = create(:zone, codeplug: codeplug, name: "Zone 2")

    assert_equal 2, codeplug.zones.count
    assert_includes codeplug.zones, zone1
    assert_includes codeplug.zones, zone2
  end

  # Name Length Tests (no validation, just storage)
  test "should store long names" do
    long_name = "A" * 100
    zone = create(:zone, name: long_name)
    assert_equal long_name, zone.name
  end

  test "should store long long_name" do
    long_long_name = "B" * 100
    zone = create(:zone, long_name: long_long_name)
    assert_equal long_long_name, zone.long_name
  end

  test "should store short short_name" do
    zone = create(:zone, short_name: "AB")
    assert_equal "AB", zone.short_name
  end

  # User Association Tests
  test "should belong to user" do
    zone = build(:zone)
    assert_respond_to zone, :user
  end

  test "user association should be configured" do
    association = Zone.reflect_on_association(:user)
    assert_not_nil association, "user association should exist"
    assert_equal :belongs_to, association.macro
  end

  # Public Flag Tests
  test "public should default to false" do
    zone = create(:zone)
    assert_equal false, zone.public
  end

  test "should save zone as public" do
    zone = create(:zone, public: true)
    assert zone.public
  end

  test "should save zone as private" do
    zone = create(:zone, public: false)
    assert_not zone.public
  end

  # Scope Tests
  test "publicly_visible scope should return public zones" do
    public_zone = create(:zone, public: true)
    private_zone = create(:zone, public: false)

    public_zones = Zone.publicly_visible
    assert_includes public_zones, public_zone
    assert_not_includes public_zones, private_zone
  end

  test "owned_by scope should return zones for specific user" do
    user1 = create(:user)
    user2 = create(:user)
    zone1 = create(:zone, user: user1)
    zone2 = create(:zone, user: user2)

    user1_zones = Zone.owned_by(user1)
    assert_includes user1_zones, zone1
    assert_not_includes user1_zones, zone2
  end

  test "available_to_user scope should return public zones and user's private zones" do
    user1 = create(:user)
    user2 = create(:user)

    # User1's zones
    user1_public_zone = create(:zone, user: user1, public: true, name: "User1 Public")
    user1_private_zone = create(:zone, user: user1, public: false, name: "User1 Private")

    # User2's zones
    user2_public_zone = create(:zone, user: user2, public: true, name: "User2 Public")
    user2_private_zone = create(:zone, user: user2, public: false, name: "User2 Private")

    # User1 should see: their own zones (public + private) + other users' public zones
    available_zones = Zone.available_to_user(user1)
    assert_includes available_zones, user1_public_zone
    assert_includes available_zones, user1_private_zone
    assert_includes available_zones, user2_public_zone
    assert_not_includes available_zones, user2_private_zone
  end

  # Authorization Method Tests
  test "editable_by? should return true for zone owner" do
    user = create(:user)
    zone = create(:zone, user: user)

    assert zone.editable_by?(user), "Owner should be able to edit their zone"
  end

  test "editable_by? should return false for non-owner" do
    owner = create(:user)
    other_user = create(:user)
    zone = create(:zone, user: owner)

    assert_not zone.editable_by?(other_user), "Non-owner should not be able to edit zone"
  end

  test "editable_by? should return false for nil user" do
    zone = create(:zone)

    assert_not zone.editable_by?(nil), "Nil user should not be able to edit zone"
  end

  test "viewable_by? should return true for public zone by any user" do
    owner = create(:user)
    other_user = create(:user)
    public_zone = create(:zone, user: owner, public: true)

    assert public_zone.viewable_by?(other_user), "Public zone should be viewable by anyone"
  end

  test "viewable_by? should return true for private zone by owner" do
    user = create(:user)
    private_zone = create(:zone, user: user, public: false)

    assert private_zone.viewable_by?(user), "Owner should be able to view their private zone"
  end

  test "viewable_by? should return false for private zone by non-owner" do
    owner = create(:user)
    other_user = create(:user)
    private_zone = create(:zone, user: owner, public: false)

    assert_not private_zone.viewable_by?(other_user), "Non-owner should not view private zone"
  end

  test "viewable_by? should return true for public zone by nil user" do
    public_zone = create(:zone, public: true)

    assert public_zone.viewable_by?(nil), "Public zone should be viewable by unauthenticated user"
  end

  test "viewable_by? should return false for private zone by nil user" do
    private_zone = create(:zone, public: false)

    assert_not private_zone.viewable_by?(nil), "Private zone should not be viewable by unauthenticated user"
  end

  # Multi-user Tests
  test "different users can create zones with same name" do
    user1 = create(:user)
    user2 = create(:user)
    zone1 = create(:zone, user: user1, name: "Zone A")
    zone2 = create(:zone, user: user2, name: "Zone A")

    assert zone1.persisted?
    assert zone2.persisted?
  end

  # Codeplug Optional Tests
  test "zone can exist without being associated to a codeplug" do
    zone = create(:zone, codeplug: nil)
    assert_nil zone.codeplug
    assert zone.persisted?
  end
end
