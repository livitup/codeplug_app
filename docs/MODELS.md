# Data Models & Relationships

## Overview

This document defines all data models for the Codeplug Application. The app follows a "Rosetta Stone" pattern where users create a single canonical codeplug that can be exported to many different radio formats.

## Core Concepts

- **System**: A radio repeater or simplex frequency with technical specifications
- **Channel**: A user's configuration to access a System (references System + adds user preferences)
- **Zone**: A logical grouping of Channels (unlimited size in app, split on export if needed)
- **Codeplug**: A user's complete radio programming (contains Zones and Channels)
- **RadioModel**: A specific make/model of radio with capabilities and limits
- **CodeplugLayout**: The CSV export format for a specific RadioModel
- **TalkGroup**: Digital radio talkgroup (DMR, P25, etc.)
- **Network**: Organization of TalkGroups (e.g., Brandmeister, DMRVA)

---

## Models

### User
Standard Rails 8 authentication model with user preferences.

**Attributes:**
- `email` (string, unique, required)
- `password_digest` (string, required)
- `name` (string)
- `callsign` (string) - ham radio callsign
- User preference columns (TBD as needed):
  - `default_power_level` (string)
  - `measurement_preference` (string) - display format preferences

**Associations:**
- `has_many :codeplugs`

**Validations:**
- Email presence and uniqueness
- Password requirements (Rails 8 default)

---

### Manufacturer
Radio manufacturers (Motorola, Baofeng, Kenwood, etc.)

**Attributes:**
- `name` (string, required, unique)

**Associations:**
- `has_many :radio_models`

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
- `frequency_ranges` (text/json) - array of hashes: `[{band: "2m", min: 144.0, max: 148.0}, {band: "70cm", min: 420.0, max: 450.0}]`

**Associations:**
- `belongs_to :manufacturer`
- `has_many :codeplug_layouts`

**Validations:**
- Manufacturer presence
- Name presence
- At least one supported mode
- Positive integers for zone/channel limits and name lengths

**Notes:**
- Frequency ranges stored as serialized array/JSON for flexibility
- Some radios are "single zone" (treat as 1 zone with X channels)

---

### CodeplugLayout
Defines CSV export format for a specific RadioModel. Stores field mappings so users can customize export formats.

**Attributes:**
- `radio_model_id` (integer, foreign key, required)
- `name` (string, required) - e.g., "Chirp CSV Format", "CPS Standard"
- `user_id` (integer, foreign key, nullable) - creator, null for system defaults
- `layout_definition` (text/json) - field mapping configuration:
  ```json
  {
    "columns": [
      {"header": "Channel Name", "maps_to": "long_name"},
      {"header": "RX Freq", "maps_to": "system.rx_frequency"},
      {"header": "TX Freq", "maps_to": "system.tx_frequency"},
      {"header": "Power", "maps_to": "power_level"}
    ]
  }
  ```

**Associations:**
- `belongs_to :radio_model`
- `belongs_to :user, optional: true`

**Validations:**
- Radio model presence
- Name presence
- Valid JSON structure for layout_definition

**Notes:**
- Users can create custom layouts via field picker interface
- System-provided layouts have `user_id: null`

---

### Network
Organization/network that operates TalkGroups (e.g., Brandmeister, DMRVA).

**Attributes:**
- `name` (string, required, unique)
- `description` (text)
- `website` (string)
- `network_type` (string) - e.g., "DMR", "P25", "NXDN"

**Associations:**
- `has_many :talkgroups`
- `has_many :system_networks`
- `has_many :systems, through: :system_networks`

**Validations:**
- Name presence and uniqueness

**Notes:**
- Users can create new networks
- Network may be specific to a digital mode or support multiple

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
- `has_many :system_talkgroups`
- `has_many :systems, through: :system_talkgroups`

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
- `bandwidth` (string) - default bandwidth (e.g., "25kHz", "12.5kHz")
- `supports_tx_tone` (boolean, default: false)
- `supports_rx_tone` (boolean, default: false)
- `tx_tone_value` (string, nullable) - e.g., "127.3", "065"
- `rx_tone_value` (string, nullable)
- `city` (string)
- `state` (string)
- `county` (string)
- `latitude` (decimal)
- `longitude` (decimal)
- `mode_detail_id` (integer, foreign key, polymorphic)
- `mode_detail_type` (string, polymorphic)

**Associations:**
- `belongs_to :mode_detail, polymorphic: true`
- `has_many :system_networks`
- `has_many :networks, through: :system_networks`
- `has_many :system_talkgroups`
- `has_many :talkgroups, through: :system_talkgroups`
- `has_many :channels`

**Validations:**
- Name, mode, tx_frequency, rx_frequency presence
- Valid mode from enum
- Frequencies within valid ranges
- Tone values from valid CTCSS/DCS list if present

**Notes:**
- Tone values stored as strings: "127.3" or "065"
- Mode-specific attributes stored in polymorphic mode_detail
- Location data optional but recommended

---

### ModeDetail (Polymorphic)
Base for mode-specific system attributes.

#### DmrModeDetail
**Attributes:**
- `color_code` (integer, required, 0-15)

**Validations:**
- Color code between 0 and 15

#### P25ModeDetail
**Attributes:**
- `nac` (string, required) - Network Access Code, e.g., "293"

**Validations:**
- NAC presence and format

#### AnalogModeDetail
**Attributes:**
- (May not need any additional attributes, or could store analog-specific settings)

**Notes:**
- Additional mode detail models (NxdnModeDetail, etc.) added as needed
- Each mode detail model has specific validations for its attributes

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
- System and network presence
- Unique combination of system_id and network_id

**Notes:**
- Most systems connected to one network, but some support multiple
- Used to filter available talkgroups when building channels

---

### SystemTalkGroup (Join Table)
Associates TalkGroups with Systems, including mode-specific attributes like timeslot.

**Attributes:**
- `system_id` (integer, foreign key, required)
- `talkgroup_id` (integer, foreign key, required)
- `timeslot` (integer, nullable) - DMR timeslot (1 or 2), null for non-DMR

**Associations:**
- `belongs_to :system`
- `belongs_to :talkgroup`
- `has_many :channels`

**Validations:**
- System and talkgroup presence
- Unique combination of system, talkgroup, and timeslot
- Timeslot 1 or 2 if present (DMR only)

**Notes:**
- Same talkgroup can be on different timeslots on different systems
- Channels reference SystemTalkGroup (not just TalkGroup) to capture timeslot

---

### Codeplug
User's complete radio programming configuration.

**Attributes:**
- `user_id` (integer, foreign key, required)
- `name` (string, required)
- `description` (text)
- `public` (boolean, default: false) - whether other users can view/clone

**Associations:**
- `belongs_to :user`
- `has_many :zones, dependent: :destroy`
- `has_many :channels, dependent: :destroy`

**Validations:**
- User presence
- Name presence

**Notes:**
- A codeplug is the "meta" configuration, independent of specific radios
- Can be exported to multiple radio formats

---

### Zone
Logical grouping of channels within a codeplug. No size limits in app (handled on export).

**Attributes:**
- `codeplug_id` (integer, foreign key, required)
- `name` (string, required)
- `long_name` (string) - for radios supporting long zone names
- `short_name` (string) - for radios requiring short zone names

**Associations:**
- `belongs_to :codeplug`
- `has_many :channel_zones, dependent: :destroy`
- `has_many :channels, through: :channel_zones`

**Validations:**
- Codeplug presence
- Name presence

**Notes:**
- Zones have unlimited channels in app
- On export, if zone exceeds radio's max_channels_per_zone, prompt user for split strategy
- Radios without zone concept treated as "single zone" with X channels

---

### Channel
User's configuration to access a System. References System and adds user/radio-specific settings.

**Attributes:**
- `codeplug_id` (integer, foreign key, required)
- `system_id` (integer, foreign key, required)
- `system_talkgroup_id` (integer, foreign key, nullable) - only for digital modes
- `name` (string, required)
- `long_name` (string)
- `short_name` (string)
- `power_level` (string) - e.g., "High", "Low", "Medium"
- `bandwidth` (string, nullable) - overrides system default if set
- `tone_mode` (string, enum) - "none", "tx_only", "rx_only", "tx_rx"
- `transmit_permission` (string, enum) - values TBD, includes "forbid_tx" option

**Associations:**
- `belongs_to :codeplug`
- `belongs_to :system`
- `belongs_to :system_talkgroup, optional: true`
- `has_many :channel_zones, dependent: :destroy`
- `has_many :zones, through: :channel_zones`

**Validations:**
- Codeplug and system presence
- Name presence
- Valid tone_mode from enum
- Valid transmit_permission from enum
- system_talkgroup required if system mode is digital (business logic)
- tone_mode must respect system's supports_tx_tone and supports_rx_tone

**Notes:**
- Channel inherits system data (frequencies, tones) and adds user preferences
- A channel can appear in multiple zones at different positions
- For digital systems, must reference a SystemTalkGroup to capture talkgroup + timeslot

---

### ChannelZone (Join Table)
Associates Channels with Zones, with position/sequence tracking.

**Attributes:**
- `channel_id` (integer, foreign key, required)
- `zone_id` (integer, foreign key, required)
- `position` (integer, required) - channel number within zone (1-based)

**Associations:**
- `belongs_to :channel`
- `belongs_to :zone`

**Validations:**
- Channel and zone presence
- Position is positive integer
- Unique position within a zone

**Notes:**
- Position determines channel order within zone
- Same channel can be at different positions in different zones
- Users can reorder channels within zones

---

## Enums

### System Mode
- `analog`
- `dmr`
- `p25`
- `nxdn`
- Additional modes added as needed

### Tone Mode
- `none` - no tones
- `tx_only` - transmit tone only
- `rx_only` - receive tone only (squelch)
- `tx_rx` - both transmit and receive tones

### Transmit Permission
- TBD - will include options like:
  - `always` - always allow transmit
  - `forbid_tx` - receive only
  - Additional options as needed

---

## CTCSS/DCS Tone Values

Tones stored as strings in database. Valid values maintained in application config/constant.

**CTCSS (Hz):**
- "67.0", "71.9", "74.4", "77.0", "79.7", "82.5", "85.4", "88.5", "91.5", "94.8", "97.4", "100.0", "103.5", "107.2", "110.9", "114.8", "118.8", "123.0", "127.3", "131.8", "136.5", "141.3", "146.2", "151.4", "156.7", "162.2", "167.9", "173.8", "179.9", "186.2", "192.8", "203.5", "210.7", "218.1", "225.7", "233.6", "241.8", "250.3"

**DCS (Codes):**
- "023", "025", "026", "031", "032", "036", "043", "047", "051", "053", "054", "065", "071", "072", "073", "074", "114", "115", "116", "122", "125", "131", "132", "134", "143", "145", "152", "155", "156", "162", "165", "172", "174", "205", "212", "223", "225", "226", "243", "244", "245", "246", "251", "252", "255", "261", "263", "265", "266", "271", "274", "306", "311", "315", "325", "331", "332", "343", "346", "351", "356", "364", "365", "371", "411", "412", "413", "423", "431", "432", "445", "446", "452", "454", "455", "462", "464", "465", "466", "503", "506", "516", "523", "526", "532", "546", "565", "606", "612", "624", "627", "631", "632", "654", "662", "664", "703", "712", "723", "731", "732", "734", "743", "754"

**Display Format:**
- CTCSS displayed with "Hz" suffix in UI: "127.3 Hz"
- DCS displayed as-is: "065"
- Export format varies by radio (some want "Hz", some don't)

---

## Business Rules & Constraints

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

### System/Network/Talkgroup Filtering
1. When user selects a System for a Channel, only show TalkGroups from Networks the System is connected to
2. Show SystemTalkGroup options (includes timeslot) rather than raw TalkGroups

### Simplex Systems
- For simplex operation (no repeater), create a System where tx_frequency == rx_frequency
- Could have a "simplex" mode or use "analog"/"dmr" mode with matching frequencies

---

## Future Considerations

Features to add in later iterations:
- Import codeplug from CSV (with auto-detect of format)
- Export history/audit log
- Codeplug versioning
- Shared/community codeplugs
- Frequency allocation validation (regulatory compliance)
- Simplex frequency library (common calling frequencies, etc.)
- Channel templates
- Bulk operations (clone channels, mass edit, etc.)

---

## Database Indexes

Recommended indexes for performance:
- `users.email` (unique)
- `radio_models.manufacturer_id`
- `systems.mode`
- `systems.latitude, systems.longitude` (for geographic queries)
- `talkgroups.network_id`
- `system_talkgroups.system_id, system_talkgroups.talkgroup_id`
- `channels.codeplug_id`
- `channels.system_id`
- `channel_zones.zone_id, channel_zones.position`
- Foreign key indexes on all join tables
