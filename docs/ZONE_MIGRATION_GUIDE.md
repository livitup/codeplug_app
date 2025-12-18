# Zone Architecture Migration Guide

This guide is for developers who need to understand the zone architecture changes implemented in Epic #91.

## Overview

The zone architecture was refactored from a direct relationship (zones embedded in codeplugs) to a template-based approach (zones as standalone, reusable entities).

## Architecture Changes

### Before (Old Architecture)

```
Codeplug
└── Zone (belongs_to :codeplug)
    └── ChannelZone → Channel

Zone.codeplug_id was required
Zones were created inside codeplugs
Zones could not be shared between codeplugs
```

### After (New Architecture)

```
Zone (standalone, owned by user)
├── ZoneSystem → System
│   └── ZoneSystemTalkGroup → SystemTalkGroup
└── CodeplugZone → Codeplug

Codeplug
├── CodeplugZone → Zone
└── Channel (generated from zones)
    ├── source_zone_id (tracks origin)
    └── ChannelZone (position in zone)
```

## Database Changes

### New Tables

1. **zone_systems**
   - Links zones to systems
   - Has `position` for ordering
   - Unique constraint on `zone_id, system_id`

2. **zone_system_talk_groups**
   - Links zone_systems to system_talk_groups
   - For digital systems (DMR, P25, NXDN)
   - Unique constraint on `zone_system_id, system_talk_group_id`

3. **codeplug_zones**
   - Links codeplugs to zones
   - Has `position` for ordering
   - Unique constraint on `codeplug_id, zone_id`

### Modified Tables

1. **zones**
   - Removed: `codeplug_id` column
   - Added: `user_id` (required, owner of the zone)
   - Added: `public` boolean (default false)

2. **channels**
   - Added: `source_zone_id` (tracks which zone generated the channel)

## Model Changes

### Zone Model

```ruby
# OLD
class Zone < ApplicationRecord
  belongs_to :codeplug
  has_many :channel_zones
  has_many :channels, through: :channel_zones
end

# NEW
class Zone < ApplicationRecord
  belongs_to :user
  has_many :zone_systems, dependent: :destroy
  has_many :systems, through: :zone_systems
  has_many :codeplug_zones, dependent: :destroy
  has_many :codeplugs, through: :codeplug_zones
  has_many :channel_zones, dependent: :destroy
  has_many :channels, through: :channel_zones

  scope :publicly_visible, -> { where(public: true) }
  scope :available_to_user, ->(user) { where(public: true).or(where(user: user)) }

  def editable_by?(user)
    self.user == user
  end

  def viewable_by?(user)
    public? || self.user == user
  end
end
```

### Codeplug Model

```ruby
# OLD
class Codeplug < ApplicationRecord
  has_many :zones, dependent: :destroy
end

# NEW
class Codeplug < ApplicationRecord
  has_many :codeplug_zones, dependent: :destroy
  has_many :zones, through: :codeplug_zones
end
```

### Channel Model

```ruby
# NEW addition
class Channel < ApplicationRecord
  belongs_to :source_zone, class_name: "Zone", optional: true

  def generated?
    source_zone_id.present?
  end
end
```

## New Models

### ZoneSystem

```ruby
class ZoneSystem < ApplicationRecord
  belongs_to :zone
  belongs_to :system
  has_many :zone_system_talkgroups, dependent: :destroy

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :system_id, uniqueness: { scope: :zone_id }
  validates :position, uniqueness: { scope: :zone_id }
end
```

### ZoneSystemTalkGroup

```ruby
class ZoneSystemTalkGroup < ApplicationRecord
  belongs_to :zone_system
  belongs_to :system_talk_group

  validates :system_talk_group_id, uniqueness: { scope: :zone_system_id }
  validate :system_talk_group_must_belong_to_zone_system_system
end
```

### CodeplugZone

```ruby
class CodeplugZone < ApplicationRecord
  belongs_to :codeplug
  belongs_to :zone

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :zone_id, uniqueness: { scope: :codeplug_id }
  validates :position, uniqueness: { scope: :codeplug_id }

  default_scope { order(position: :asc) }
end
```

## Service Classes

### ChannelGenerator

New service for generating channels from zones:

```ruby
generator = ChannelGenerator.new(codeplug)
result = generator.generate_channels(regenerate: false)
# => { channels_created: 5, channel_zones_created: 5, zones_processed: 2, skipped: false }
```

**Behavior:**
- Processes zones in CodeplugZone position order
- For analog systems: creates one channel per system
- For digital systems: creates one channel per ZoneSystemTalkGroup
- Sets `source_zone_id` on generated channels
- With `regenerate: true`: destroys existing channels first

## Route Changes

### Removed Routes

```ruby
# OLD - nested zones under codeplugs
resources :codeplugs do
  resources :zones do
    resources :channel_zones
  end
end
```

### New Routes

```ruby
# Standalone zones
resources :zones do
  resources :zone_systems, only: [:create, :destroy]
  member do
    patch :update_positions
  end
end

# Zone-system talkgroups
resources :zone_systems do
  resources :zone_system_talkgroups, only: [:create, :destroy]
end

# Codeplug zones (linking zones to codeplugs)
resources :codeplugs do
  resources :codeplug_zones, only: [:create, :destroy] do
    collection do
      patch :update_positions
    end
  end
  member do
    post :generate_channels
  end
end
```

## Data Migration

A rake task is provided for migrating existing data:

```bash
# Analyze existing data
rails zones:analyze

# Perform migration
rails zones:migrate

# Verify migration
rails zones:verify

# Rollback if needed
rails zones:rollback

# Clear legacy codeplug_id after verification
rails zones:clear_legacy_codeplug_ids
```

## Testing Changes

### Factory Updates

```ruby
# OLD
factory :zone do
  association :codeplug
end

# NEW
factory :zone do
  association :user
  public { false }
end
```

### Test Updates

Replace direct zone-codeplug creation with CodeplugZone:

```ruby
# OLD
zone = create(:zone, codeplug: codeplug)

# NEW
zone = create(:zone, user: user)
create(:codeplug_zone, codeplug: codeplug, zone: zone, position: 1)
```

## Breaking Changes

1. **Zone no longer has `codeplug_id`**
   - Zones are standalone entities
   - Use `CodeplugZone` to link zones to codeplugs

2. **Zone requires `user_id`**
   - All zones must have an owner
   - Owner controls edit permissions

3. **Nested zone routes removed**
   - `/codeplugs/:id/zones` routes no longer exist
   - Use `/zones` for zone management
   - Use `/codeplugs/:id/codeplug_zones` for adding zones to codeplugs

4. **Channel generation is explicit**
   - Channels are not auto-created
   - User must click "Generate Channels"
   - Regeneration destroys existing channels

## Upgrade Steps

1. Run database migrations
2. Run `rails zones:migrate` to migrate existing data
3. Run `rails zones:verify` to check data integrity
4. Update any custom code that references `zone.codeplug`
5. Update tests to use new factory patterns
6. Run `rails zones:clear_legacy_codeplug_ids` after verification

## Common Issues

### "undefined method 'codeplug=' for Zone"

Code is using the old direct relationship. Update to use CodeplugZone:

```ruby
# OLD
zone.codeplug = codeplug

# NEW
CodeplugZone.create!(codeplug: codeplug, zone: zone, position: 1)
```

### "Zone must have user"

Zones now require an owner. Ensure user is set:

```ruby
zone = Zone.create!(user: current_user, name: "My Zone")
```

### Tests failing with "codeplug_id doesn't exist"

Update test factories and setup to use new architecture:

```ruby
# In test setup
user = create(:user)
codeplug = create(:codeplug, user: user)
zone = create(:zone, user: user)
create(:codeplug_zone, codeplug: codeplug, zone: zone, position: 1)
```

## Related Issues

- Epic: #91 - Zone Architecture Refactor
- Issue #97: Add systems to zones
- Issue #98: Add talkgroup selection for digital systems
- Issue #99: Add zones to codeplugs
- Issue #100: Implement zone reordering
- Issue #101: Channel generation service
- Issue #102: Generate channels button
- Issue #103: Channel customization after generation
- Issue #104: Zone data migration
- Issue #105: Remove old zone relationships
- Issue #106: Documentation and UI polish
