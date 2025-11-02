# Codeplug Application - AI Assistant Instructions

## Project Overview

This Rails 8 application helps users manage two-way radio programming data (codeplugs). The app serves as a "Rosetta Stone" - users create a single canonical codeplug that can be exported to multiple radio-specific CSV formats.

### Primary Use Cases

1. **Universal Codeplug Management**: Users define channels, zones, systems, and talkgroups once in a universal format
2. **Multi-Radio Export**: Export codeplugs to CSV formats for dozens of different radio makes/models
3. **Community Resources**: Shared database of repeaters, talkgroups, and networks
4. **Custom Radio Support**: Users can create new radio model definitions and CSV export layouts

### Key Users
- Ham radio operators
- Radio programmers managing multiple radio types
- Community contributors adding repeater/talkgroup data

---

## Development Workflow - STRICT TDD

This project **strictly follows Test-Driven Development (TDD)** principles:

### TDD Cycle (Mandatory)
```
1. Write failing test
2. Run test (verify it fails)
3. Write minimum code to pass
4. Run test (verify it passes)
5. Refactor while keeping tests green
6. Repeat
```

### Absolute Rules
- **NO code without tests first**
- **NO PRs with failing tests** - even if failures are unrelated to your changes
- **ALL tests must pass** before any PR creation (`rails test:all`, `rubocop -a`, `brakeman`)
- **Red-Green-Refactor** workflow is mandatory

### Before Every PR
```bash
rails test:all   # All unit, integration, and system tests must pass
rubocop -a       # Auto-fix and check style violations
brakeman         # No security issues
```

If ANY test fails (even outside your changes), you MUST fix it before creating the PR. No exceptions.

---

## Architecture & Technology Stack

### Backend
- **Rails 8** - Latest stable with built-in authentication (no Devise)
- **Ruby 3.x** - Version in `.ruby-version`
- **PostgreSQL** - Database (version 12 or higher recommended)
- **Solid Queue** - Background jobs (Rails 8 default)
- **Solid Cache** - Caching (Rails 8 default)

### Frontend
- **Hotwire (Turbo + Stimulus)** - Modern Rails frontend
- **Bootstrap 5** - CSS framework
- **esbuild** - JavaScript bundling
- **No Active Storage** - CSVs are transient (upload → process → download, never stored)

### Testing
- **Minitest** - Rails default (not RSpec)
- **Capybara** - System/integration tests
- **Fixtures** - Test data

### Deployment
- **Kamal** - Deployment tool
- **Docker** - Containerization

---

## Core Data Models

See `docs/MODELS.md` for complete specifications. Key models:

### User & Ownership
- `User` - Rails 8 authentication, owns codeplugs
- `Codeplug` - User's complete radio configuration (can be public/private)

### Radio Hardware (Shared/Universal)
- `Manufacturer` - Radio manufacturers (Motorola, Baofeng, etc.)
- `RadioModel` - Specific radio with capabilities (zones, channels, name lengths, frequency ranges)
- `CodeplugLayout` - CSV export format definition for a radio model

### Repeater Infrastructure (Shared/Public)
- `System` - Repeater or simplex frequency with technical specs
- `ModeDetail` (polymorphic) - Mode-specific attributes (DmrModeDetail, P25ModeDetail, etc.)
- `Network` - Talkgroup organization (Brandmeister, DMRVA, etc.)
- `TalkGroup` - Digital radio talkgroup

### Join Tables with Metadata
- `SystemNetwork` - Systems can be on multiple networks
- `SystemTalkGroup` - Talkgroup + timeslot per system
- `ChannelZone` - Channel position within zone

### User's Configuration
- `Zone` - Logical grouping of channels (unlimited size in app)
- `Channel` - User's configuration to access a System (references System + adds settings)

### Key Relationships
- Channel → System (pulls in frequencies, tones)
- Channel → SystemTalkGroup (for digital: talkgroup + timeslot)
- Channel ↔ Zone (many-to-many with position)
- System → ModeDetail (polymorphic: analog/DMR/P25/etc.)

---

## Code Organization Patterns

### When to Use Service Objects
- Complex multi-step operations
- CSV export/import logic
- Orchestrating multiple models
- Example: `CodeplugExporter`, `CsvImporter`

### When to Use Form Objects
- Forms spanning multiple models
- Complex validation logic
- Non-RESTful form flows
- Example: `ChannelBuilderForm`

### When to Use Concerns
- Shared validations across models
- Common query scopes
- Reusable behavior
- Example: `Nameable`, `Geolocatable`

### When to Use Query Objects
- Complex database queries
- Filtering logic used in multiple places
- Example: `AvailableTalkgroupsQuery`

---

## Testing Strategy

### Model Tests (`test/models/`)
Test:
- Validations
- Associations
- Scopes
- Instance methods
- Class methods

### Controller Tests (`test/controllers/`)
Test:
- HTTP responses
- Redirects
- Flash messages
- Authorization
- Strong parameters

### System Tests (`test/system/`)
Test complete user workflows:
- User registration/login
- Creating codeplugs
- Adding channels to zones
- Exporting to CSV
- Reordering channels

### Service Tests (`test/services/`)
Test business logic:
- CSV export formatting
- Zone splitting logic
- Import validation

---

## Seed Data for Development

### Purpose
Seed data (`db/seeds.rb`) provides realistic test data for development environments, making it easy to develop and test features without manually creating records.

### Requirements for All Models
When implementing new models, **always add seed data** to `db/seeds.rb`:

- **User**: Create at least one seed user with documented credentials
- **Lookup/Reference Data**: Create comprehensive seed data (manufacturers, networks, etc.)
- **Realistic Data**: Use realistic values that represent actual use cases
- **Idempotent**: Use `find_or_create_by` so seeds can be run multiple times
- **Environment-specific**: Only run in development (`if Rails.env.development?`)
- **Helpful Output**: Add messages (e.g., "Created 7 manufacturers...")

### Seed User Credentials
Document seed user credentials in README.md so developers know how to log in:
- Email: `dev@example.com`
- Password: `password123`

### Example
```ruby
if Rails.env.development?
  # Create seed user
  user = User.find_or_create_by!(email: 'dev@example.com') do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.name = 'Dev User'
    u.callsign = 'W1DEV'
  end
  puts "Created seed user: #{user.email}"

  # Create manufacturers
  manufacturers = ['Motorola', 'Baofeng', 'Anytone'].map do |name|
    Manufacturer.find_or_create_by!(name: name)
  end
  puts "Created #{manufacturers.count} manufacturers"
end
```

---

## Important Business Logic

### Polymorphic Mode Details
Systems have different attributes based on mode:
- **DMR**: color_code (0-15)
- **P25**: nac (network access code)
- **Analog**: basic repeater settings
- **NXDN**, etc.: mode-specific attributes

Use polymorphic association: `System belongs_to :mode_detail, polymorphic: true`

### Channel/System/TalkGroup Relationship
- Channel references a **System** (gets frequencies, tones)
- For digital systems, Channel references **SystemTalkGroup** (includes timeslot)
- Channel adds user preferences (power, bandwidth override, tone_mode)

### Tone Handling
- System has `tx_tone_value` and `rx_tone_value` (CTCSS/DCS codes)
- System has `supports_tx_tone` and `supports_rx_tone` (booleans)
- Channel has `tone_mode` enum: none, tx_only, rx_only, tx_rx
- Channel can only use tones if System supports them
- Tones stored as strings: "127.3" (CTCSS) or "065" (DCS)
- Display with/without "Hz" based on export format

### Zone/Channel Position
- Zones have unlimited channels in app
- Join table `ChannelZone` has `position` (channel number within zone)
- Same channel can be in multiple zones at different positions
- Users can reorder channels (drag-and-drop UI)

### Zone Splitting on Export
- Logical zones in app can have unlimited channels
- On export, if zone exceeds `RadioModel.max_channels_per_zone`:
  - Prompt user for split strategy (e.g., 30 channels → 16/14 or 15/15)
  - Generate multiple physical zones in CSV
  - Maintain channel order via position

### CSV Export
- Each RadioModel has one or more CodeplugLayouts
- Layout stores field mappings (JSON):
  ```json
  {
    "columns": [
      {"header": "Channel Name", "maps_to": "long_name"},
      {"header": "RX Freq", "maps_to": "system.rx_frequency"}
    ]
  }
  ```
- Export service maps codeplug data → CSV format
- No storage needed: generate → stream → download

### CSV Import
- User uploads CSV
- Service detects/validates format
- Creates/updates records
- Optionally: auto-detect format and create new CodeplugLayout (future feature)

---

## Rails Conventions to Follow

### Controllers
- RESTful routes preferred
- Skinny controllers (delegate to services/models)
- Use strong parameters
- Handle format.turbo_stream for Hotwire responses

### Models
- Fat models for domain logic
- Use concerns for shared behavior
- Validations at model level
- Scopes for common queries

### Views
- Partials for reusable components
- Turbo Frames for independent sections
- Turbo Streams for dynamic updates
- Stimulus controllers for JS interactions

### Routes
- Resourceful routes where possible
- Member/collection actions for custom endpoints
- Nested routes for clear relationships

---

## Hotwire/Turbo Patterns

### Turbo Drive
- Automatic (speeds up page navigation)

### Turbo Frames
- Use for independent page sections
- Example: Channel form in a frame, updates without full page reload

### Turbo Streams
- Use for create/update/delete operations
- Replace/append/prepend DOM elements
- Example: Adding a channel updates zone display via stream

### Stimulus Controllers
- Keep JS minimal
- Use for:
  - Drag-and-drop reordering
  - Dynamic form field showing/hiding
  - CSV field picker interface
  - Client-side validations

---

## Security Considerations

### Authentication
- Rails 8 built-in (session-based, bcrypt passwords)
- No Devise needed

### Authorization
- Users own their Codeplugs
- Systems/Networks/TalkGroups are shared (public read)
- Codeplugs have public/private flag
- Check ownership in controller before edit/destroy

### Input Validation
- Strong parameters in controllers
- Model validations
- CSV parsing with error handling
- Sanitize user input (Rails auto-escapes in views)

### File Upload
- CSV only (validate format)
- Limit file size
- Parse safely (Ruby CSV library)
- Never store uploaded files (process in memory)

---

## Common Gotchas

### TalkGroup Timeslots
- Same TalkGroup can be on different timeslots on different Systems
- Don't associate Channel → TalkGroup directly
- Use Channel → SystemTalkGroup (includes timeslot)

### Zone Size Limits
- Zones unlimited in app
- Split only on export to specific radio
- Don't validate zone size against radio limits until export

### Frequency Ranges
- RadioModel stores multiple ranges (dual-band, tri-band)
- Store as JSON array: `[{band: "2m", min: 144.0, max: 148.0}]`
- Validate channel frequencies against system capabilities

### Name Length Constraints
- RadioModels have different name length limits
- Store long_name and short_name on Channels/Zones
- Truncate/warn on export if exceeds radio's limits

### Simplex Channels
- Use a System where tx_frequency == rx_frequency
- Can still have mode (analog/DMR/etc.)

---

## Testing Best Practices

### Fixtures
- Use fixtures for test data (`test/fixtures/`)
- Keep fixtures realistic
- Use associations (`channel_one: system: system_one`)

### Test Naming
- Descriptive test names: `test "should not save channel without name"`
- Group related tests in same file

### System Tests
- Test happy path workflows
- Test error cases (form validation, etc.)
- Use `assert_text` to verify UI updates
- Use `fill_in`, `select`, `click_on` for interactions

### Test Coverage
- Aim for high coverage (not 100% obsession, but thorough)
- Test validations, associations, methods
- Test controller actions (happy + error paths)
- Test key user workflows end-to-end

---

## Git Workflow

### Branches
- Feature branches from `main`
- Naming: `feature/issue-number-brief-description` (e.g., `feature/22-radio-model-views`)
- **ONE branch per issue ticket** - each GitHub issue gets its own dedicated branch and PR

### Commits
- Clear, present-tense messages
- Reference issues if applicable
- Atomic commits (one logical change per commit)

### Pull Requests
- All tests pass before creating PR
- Clear description of changes
- Screenshots for UI changes
- Squash merge to keep main clean
- **IMPORTANT**: Always stop and ask for user confirmation before creating a PR
- **After creating PR**: Check for blocked tickets in the same epic and update any that can now move to "ready" state

---

## Documentation

### When to Update Docs
- New models → update `docs/MODELS.md`
- Architectural changes → update `docs/ARCHITECTURE.md`
- New features → update `README.md`
- AI instructions → update this file

### Code Comments
- Explain WHY, not WHAT
- Document complex algorithms
- Note edge cases
- Reference external docs (radio specs, mode standards)

---

## Performance

### Database
- Add indexes on foreign keys
- Index frequently queried columns (email, lat/lng)
- Use `includes` to avoid N+1 queries

### Caching
- Fragment cache for expensive views
- Cache shared resources (systems, networks)
- Use Solid Cache (Rails 8 default)

### Background Jobs
- Use for slow operations (large CSV exports)
- Solid Queue (Rails 8 default)

---

## Deployment (Kamal)

### Commands
```bash
kamal setup      # First-time
kamal deploy     # Deploy changes
kamal app logs   # View logs
kamal rollback   # Rollback
```

### Environment Variables
- `RAILS_MASTER_KEY` - from config/master.key
- `DATABASE_URL` - production database connection

---

## Helpful Commands

### Development
```bash
bin/dev                    # Start all servers
bin/rails db:reset         # Reset database
bin/rails db:seed          # Seed data
```

### Testing
```bash
rails test                 # Unit/integration tests
rails test:system          # Browser tests
rails test:all             # All tests
rails test path/to/test.rb # Single test file
```

### Code Quality
```bash
rubocop -a                 # Auto-fix and check style
brakeman                   # Security scan
```

### Console
```bash
rails console              # Development console
rails console --sandbox    # Rollback on exit
```

---

## AI Assistant Guidelines

When helping with this project:

1. **Always start with tests** - Write failing test before implementation
2. **Follow TDD cycle** - Red → Green → Refactor
3. **One branch per issue** - Each GitHub issue ticket gets its own dedicated branch and PR
4. **Use Rails conventions** - RESTful routes, skinny controllers, etc.
5. **Reference docs** - Check `docs/MODELS.md` and `docs/ARCHITECTURE.md`
6. **Ask clarifying questions** - Domain knowledge (radios) may be unclear
7. **Consider performance** - N+1 queries, indexes, caching
8. **Think about UI/UX** - Hotwire for dynamic interactions
9. **Security first** - Validate input, check authorization
10. **Keep it simple** - KISS principle, don't over-engineer
11. **Document decisions** - Update docs for significant changes
12. **Create seed data** - When implementing new models, add realistic seed data to `db/seeds.rb` for development
13. **STOP before PRs** - Always ask for user confirmation before creating pull requests
14. **After PRs** - Check for blocked tickets in the same epic and update any that can now move to "ready" state

---

## Domain Knowledge References

### Radio Terminology
- **Repeater**: Radio infrastructure that receives and retransmits signals
- **Simplex**: Direct radio-to-radio communication (no repeater)
- **CTCSS/DCS**: Tone codes for selective squelch (privacy codes)
- **DMR**: Digital Mobile Radio (digital mode with timeslots and color codes)
- **P25**: Project 25 (digital mode with NAC)
- **Talkgroup**: Virtual channel in digital radio systems
- **Timeslot**: DMR has 2 timeslots per frequency
- **Zone**: Group of channels on a radio

### Frequency Bands (Ham Radio)
- **2m**: 144-148 MHz (VHF)
- **70cm**: 420-450 MHz (UHF)
- Additional bands: 6m, 1.25m, etc.

### CSV Export Formats
- Each radio manufacturer has different CSV formats
- Even within brands, models may differ
- Common software: CHIRP, CPS, KPG, etc.

---

## Quick Reference

**Test Command**: `rails test:all && rubocop -a && brakeman`

**Start Dev**: `bin/dev`

**Key Docs**:
- Models: `docs/MODELS.md`
- Architecture: `docs/ARCHITECTURE.md`
- Setup: `README.md`

**Key Principles**:
- TDD always
- Rails conventions
- No failing tests in PRs
- Simple over clever

---

**Last Updated**: 2025-11-01
