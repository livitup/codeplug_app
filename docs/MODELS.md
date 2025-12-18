# Data Models & Relationships

## Overview

This document defines all data models for the Codeplug Application. The app follows a "Rosetta Stone" pattern where users create a single canonical codeplug that can be exported to many different radio formats.

## Core Concepts

- **System**: A radio repeater or simplex frequency with technical specifications (shared resource)
- **Zone**: A standalone template defining which systems and talkgroups to include (owned by user, can be public/private)
- **Channel**: A user's configuration to access a System, generated from zones or created manually
- **Codeplug**: A user's complete radio programming configuration (contains generated channels, references zones)
- **RadioModel**: A specific make/model of radio with capabilities and limits
- **CodeplugLayout**: The CSV export format for a specific RadioModel
- **TalkGroup**: Digital radio talkgroup (DMR, P25, etc.)
- **Network**: Organization of TalkGroups (e.g., Brandmeister, DMRVA)

---

## Zone Architecture Overview

The zone architecture follows a template-based approach:

```
Zone (template, owned by user)
├── ZoneSystem (systems in this zone)
│   └── ZoneSystemTalkGroup (talkgroups for digital systems)
└── Linked to Codeplugs via CodeplugZone

Codeplug (user's radio configuration)
├── CodeplugZone (references to zones, ordered)
└── Channels (generated from zones or manual)
    └── ChannelZone (channel position within zones)
```

**Workflow:**
1. User creates standalone Zones with Systems and Talkgroups
2. User adds Zones to a Codeplug via CodeplugZone
3. User clicks "Generate Channels" to create Channels from the zones
4. Channels are created with `source_zone_id` tracking their origin
5. User can customize generated channels (changes persist until regeneration)

---

## Models

### User
Standard Rails 8 authentication model with user preferences.

**Attributes:**
- `email` (string, unique, required)
- `password_digest` (string, required)
- `name` (string)
- `callsign` (string) - ham radio callsign
- `default_power_level` (string)
- `measurement_preference` (string) - display format preferences

**Associations:**
- `has_many :codeplugs`
- `has_many :zones` - standalone zones owned by user

**Validations:**
- Email presence and uniqueness
- Password requirements (Rails 8 default)

---

### Manufacturer
Radio manufacturers (Motorola, Baofeng, Kenwood, etc.)

**Attributes:**
- `name` (string, required, unique)
- `system_record` (boolean) - true for system-provided records
- `user_id` (integer, foreign key, nullable) - creator for user-defined records

**Associations:**
- `has_many :radio_models`
- `belongs_to :user, optional: true`

**Validations:**
- Name presence and uniqueness

---

### RadioModel
Specific radio make/model with capabilities and constraints.

**Attributes:**
- `manufacturer_id` (integer, foreign key, required)
- `name` (string, required) - e.g., "UV-5R", "APX 8000"
- `supported_modes` (text, array) - ["analog", "dmr", "p25", etc.]
- `max_zones` (integer) - maximum number of zones, null if unlimited
- `max_channels_per_zone` (integer) - maximum channels per zone
- `long_channel_name_length` (integer)
- `short_channel_name_length` (integer)
- `long_zone_name_length` (integer)
- `short_zone_name_length` (integer)
- `frequency_ranges` (text/json) - array of hashes
- `system_record` (boolean) - true for system-provided records
- `user_id` (integer, foreign key, nullable) - creator for user-defined records

**Associations:**
- `belongs_to :manufacturer`
- `belongs_to :user, optional: true`
- `has_many :codeplug_layouts`

**Validations:**
- Manufacturer presence
- Name presence
- At least one supported mode

---

### CodeplugLayout
Defines CSV export format for a specific RadioModel.

**Attributes:**
- `radio_model_id` (integer, foreign key, required)
- `name` (string, required) - e.g., "Chirp CSV Format", "CPS Standard"
- `user_id` (integer, foreign key, nullable) - creator, null for system defaults
- `layout_definition` (text/json) - field mapping configuration

**Associations:**
- `belongs_to :radio_model`
- `belongs_to :user, optional: true`

**Validations:**
- Radio model presence
- Name presence
- Valid JSON structure for layout_definition

---

### Network
Organization/network that operates TalkGroups (e.g., Brandmeister, DMRVA).

**Attributes:**
- `name` (string, required, unique)
- `description` (text)
- `website` (string)
- `network_type` (string) - e.g., "Digital-DMR", "Digital-P25", "Digital-NXDN"

**Associations:**
- `has_many :talk_groups`
- `has_many :system_networks`
- `has_many :systems, through: :system_networks`

**Validations:**
- Name presence and uniqueness

---

### TalkGroup
Digital radio talkgroup identifier (DMR, P25, etc.).

**Attributes:**
- `network_id` (integer, foreign key, required)
- `name` (string, required) - e.g., "Virginia", "Worldwide"
- `talkgroup_number` (string, required) - e.g., "3181", "91"
- `description` (text)

**Associations:**
- `belongs_to :network`
- `has_many :system_talk_groups`
- `has_many :systems, through: :system_talk_groups`

**Validations:**
- Network presence
- Name and talkgroup_number presence
- Unique talkgroup_number within network

**Notes:**
- Talkgroup numbers stored as strings to handle leading zeros
- Same talkgroup can be on different timeslots on different systems

---

### System
A radio repeater or simplex frequency with technical specifications. Shared across all users.

**Attributes:**
- `name` (string, required) - e.g., "W4ABC Repeater"
- `mode` (string, required, enum) - "analog", "dmr", "p25", "nxdn", etc.
- `tx_frequency` (decimal, required) - repeater transmit (radio receive)
- `rx_frequency` (decimal, required) - repeater receive (radio transmit)
- `bandwidth` (string) - default bandwidth
- `supports_tx_tone` (boolean, default: false)
- `supports_rx_tone` (boolean, default: false)
- `tx_tone_value` (string, nullable)
- `rx_tone_value` (string, nullable)
- `city`, `state`, `county` (strings)
- `latitude`, `longitude` (decimals)
- `mode_detail_id` (integer, foreign key, polymorphic)
- `mode_detail_type` (string, polymorphic)

**Associations:**
- `belongs_to :mode_detail, polymorphic: true`
- `has_many :system_networks`
- `has_many :networks, through: :system_networks`
- `has_many :system_talk_groups`
- `has_many :talk_groups, through: :system_talk_groups`
- `has_many :channels`
- `has_many :zone_systems`
- `has_many :zones, through: :zone_systems`

**Validations:**
- Name, mode, tx_frequency, rx_frequency presence
- Valid mode from enum
- Frequencies within valid ranges

---

### ModeDetail (Polymorphic)
Base for mode-specific system attributes.

#### DmrModeDetail
**Attributes:**
- `color_code` (integer, required, 0-15)

#### P25ModeDetail
**Attributes:**
- `nac` (string, required) - Network Access Code

#### AnalogModeDetail
**Attributes:**
- (No additional attributes needed)

---

### SystemNetwork (Join Table)
Associates Systems with Networks (many-to-many).

**Attributes:**
- `system_id` (integer, foreign key, required)
- `network_id` (integer, foreign key, required)

**Associations:**
- `belongs_to :system`
- `belongs_to :network`

**Validations:**
- Unique combination of system_id and network_id

---

### SystemTalkGroup (Join Table)
Associates TalkGroups with Systems, including timeslot for DMR.

**Attributes:**
- `system_id` (integer, foreign key, required)
- `talk_group_id` (integer, foreign key, required)
- `timeslot` (integer, nullable) - DMR timeslot (1 or 2)

**Associations:**
- `belongs_to :system`
- `belongs_to :talk_group`
- `has_many :channels`
- `has_many :zone_system_talk_groups`

**Validations:**
- System and talk_group presence
- Unique combination of system, talk_group, and timeslot
- Timeslot 1 or 2 if present (DMR only)

---

### Codeplug
User's complete radio programming configuration.

**Attributes:**
- `user_id` (integer, foreign key, required)
- `name` (string, required)
- `description` (text)
- `public` (boolean, default: false)

**Associations:**
- `belongs_to :user`
- `has_many :channels, dependent: :destroy`
- `has_many :codeplug_zones, dependent: :destroy`
- `has_many :zones, through: :codeplug_zones`

**Validations:**
- User presence
- Name presence

**Notes:**
- Zones are linked via CodeplugZone (many-to-many)
- Channels are generated from zones or created manually
- Can be exported to multiple radio formats

---

### Zone
Standalone template defining which systems and talkgroups to include. Owned by a user and can be public or private.

**Attributes:**
- `user_id` (integer, foreign key, required)
- `name` (string, required)
- `long_name` (string) - for radios supporting long zone names
- `short_name` (string) - for radios requiring short zone names
- `public` (boolean, default: false) - whether other users can view/use

**Associations:**
- `belongs_to :user`
- `has_many :zone_systems, dependent: :destroy`
- `has_many :systems, through: :zone_systems`
- `has_many :codeplug_zones, dependent: :destroy`
- `has_many :codeplugs, through: :codeplug_zones`
- `has_many :channel_zones, dependent: :destroy`
- `has_many :channels, through: :channel_zones`

**Scopes:**
- `publicly_visible` - zones marked as public
- `owned_by(user)` - zones owned by specific user
- `available_to_user(user)` - public zones OR owned by user

**Methods:**
- `editable_by?(user)` - true if user owns the zone
- `viewable_by?(user)` - true if public OR owned by user

**Validations:**
- User presence
- Name presence

**Notes:**
- Zones are templates, not containers
- Public zones can be added to any user's codeplug
- Systems and talkgroups define what channels will be generated

---

### ZoneSystem (Join Table)
Associates Systems with Zones, with position tracking.

**Attributes:**
- `zone_id` (integer, foreign key, required)
- `system_id` (integer, foreign key, required)
- `position` (integer, required) - order within zone

**Associations:**
- `belongs_to :zone`
- `belongs_to :system`
- `has_many :zone_system_talkgroups, dependent: :destroy`
- `has_many :system_talkgroups, through: :zone_system_talkgroups`

**Validations:**
- Zone and system presence
- Position > 0
- Unique system within zone
- Unique position within zone

**Notes:**
- Position determines system order when generating channels
- For digital systems, talkgroups are added via ZoneSystemTalkGroup

---

### ZoneSystemTalkGroup (Join Table)
Associates SystemTalkGroups with ZoneSystems for digital modes.

**Attributes:**
- `zone_system_id` (integer, foreign key, required)
- `system_talk_group_id` (integer, foreign key, required)

**Associations:**
- `belongs_to :zone_system`
- `belongs_to :system_talk_group`

**Validations:**
- ZoneSystem and SystemTalkGroup presence
- Unique combination
- SystemTalkGroup must belong to the same system as the ZoneSystem

**Notes:**
- Only used for digital systems (DMR, P25, NXDN)
- Each ZoneSystemTalkGroup results in one generated channel

---

### CodeplugZone (Join Table)
Associates Zones with Codeplugs, with position tracking.

**Attributes:**
- `codeplug_id` (integer, foreign key, required)
- `zone_id` (integer, foreign key, required)
- `position` (integer, required) - order within codeplug

**Associations:**
- `belongs_to :codeplug`
- `belongs_to :zone`

**Validations:**
- Codeplug and zone presence
- Position > 0
- Unique zone within codeplug
- Unique position within codeplug

**Default Scope:**
- Ordered by position ascending

**Notes:**
- Position determines zone order when generating channels
- Same zone can be in multiple codeplugs

---

### Channel
User's configuration to access a System. Can be generated from zones or created manually.

**Attributes:**
- `codeplug_id` (integer, foreign key, required)
- `system_id` (integer, foreign key, required)
- `system_talk_group_id` (integer, foreign key, nullable) - only for digital modes
- `source_zone_id` (integer, foreign key, nullable) - zone this channel was generated from
- `name` (string, required)
- `long_name` (string)
- `short_name` (string)
- `power_level` (string)
- `bandwidth` (string, nullable)
- `tone_mode` (string, enum) - "none", "tx_only", "rx_only", "tx_rx"
- `transmit_permission` (string, enum) - "allow", "forbid_tx"

**Associations:**
- `belongs_to :codeplug`
- `belongs_to :system`
- `belongs_to :system_talk_group, optional: true`
- `belongs_to :source_zone, class_name: "Zone", optional: true`
- `has_many :channel_zones, dependent: :destroy`
- `has_many :zones, through: :channel_zones`

**Methods:**
- `generated?` - true if source_zone_id is present

**Validations:**
- Codeplug and system presence
- Name presence
- Valid tone_mode from enum
- Valid transmit_permission from enum

**Notes:**
- `source_zone_id` tracks which zone the channel was generated from
- Generated channels can be customized; changes persist until regeneration
- For digital systems, must reference a SystemTalkGroup

---

### ChannelZone (Join Table)
Associates Channels with Zones, with position tracking.

**Attributes:**
- `channel_id` (integer, foreign key, required)
- `zone_id` (integer, foreign key, required)
- `position` (integer, required) - channel number within zone (1-based)

**Associations:**
- `belongs_to :channel`
- `belongs_to :zone`

**Validations:**
- Channel and zone presence
- Position > 0
- Unique position within zone

**Notes:**
- Position determines channel order within zone
- Same channel can be at different positions in different zones

---

## Enums

### System Mode
- `analog`
- `dmr`
- `p25`
- `nxdn`

### Tone Mode
- `none` - no tones
- `tx_only` - transmit tone only
- `rx_only` - receive tone only (squelch)
- `tx_rx` - both transmit and receive tones

### Transmit Permission
- `allow` - transmit allowed
- `forbid_tx` - receive only

---

## Services

### ChannelGenerator
Service class that generates channels from zones for a codeplug.

**Usage:**
```ruby
generator = ChannelGenerator.new(codeplug)
result = generator.generate_channels(regenerate: false)
# => { channels_created: 5, channel_zones_created: 5, zones_processed: 2, skipped: false }
```

**Behavior:**
- For analog systems: creates one channel per system
- For digital systems: creates one channel per ZoneSystemTalkGroup
- Sets `source_zone_id` on generated channels
- Creates ChannelZone records with correct positions
- With `regenerate: true`: destroys existing channels first
- Without `regenerate`: skips if channels already exist

---

## Business Rules & Constraints

### Zone Architecture
1. Zones are standalone entities owned by users
2. Zones can be public (viewable/usable by all) or private
3. Zones define systems and talkgroups, not channels directly
4. Zones are linked to codeplugs via CodeplugZone
5. Channels are generated from zones using ChannelGenerator

### Channel Generation Logic
1. Process zones in CodeplugZone position order
2. Within each zone, process systems in ZoneSystem position order
3. For analog systems: create one channel per system
4. For digital systems: create one channel per ZoneSystemTalkGroup
5. Set source_zone_id to track origin
6. Create ChannelZone with sequential positions

### Channel/System/Talkgroup Logic
1. If system mode is digital, channel must reference a system_talkgroup
2. If system mode is analog, channel should not reference a system_talkgroup
3. Channel tone_mode options limited by system's supports_tx_tone and supports_rx_tone

### Zone/Channel Export Logic
1. Zones have unlimited channels in app
2. On export to RadioModel:
   - Check RadioModel.max_channels_per_zone
   - If zone exceeds limit, prompt user for split strategy
   - Generate physical zones on-the-fly during export

---

## CTCSS/DCS Tone Values

Tones stored as strings in database.

**CTCSS (Hz):**
- "67.0", "71.9", "74.4", "77.0", "79.7", "82.5", "85.4", "88.5", "91.5", "94.8", "97.4", "100.0", "103.5", "107.2", "110.9", "114.8", "118.8", "123.0", "127.3", "131.8", "136.5", "141.3", "146.2", "151.4", "156.7", "162.2", "167.9", "173.8", "179.9", "186.2", "192.8", "203.5", "210.7", "218.1", "225.7", "233.6", "241.8", "250.3"

**DCS (Codes):**
- "023", "025", "026", "031", "032", "036", "043", "047", "051", "053", "054", "065", "071", "072", "073", "074", etc.

---

## Database Indexes

Recommended indexes for performance:
- `users.email` (unique)
- `zones.user_id`
- `zones.public`
- `zone_systems.zone_id, zone_systems.position` (unique)
- `zone_systems.zone_id, zone_systems.system_id` (unique)
- `zone_system_talk_groups.zone_system_id, zone_system_talk_groups.system_talk_group_id` (unique)
- `codeplug_zones.codeplug_id, codeplug_zones.position` (unique)
- `codeplug_zones.codeplug_id, codeplug_zones.zone_id` (unique)
- `channels.codeplug_id`
- `channels.system_id`
- `channels.source_zone_id`
- `channel_zones.zone_id, channel_zones.position` (unique)
- Foreign key indexes on all join tables
