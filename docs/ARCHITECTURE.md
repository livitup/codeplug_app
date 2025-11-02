# Architecture Overview

## Application Purpose

The Codeplug Application is a web-based tool for managing two-way radio programming data. It serves as a "Rosetta Stone" for radio codeplugs - users create a single canonical codeplug in the app that can be exported to dozens of different CSV formats for various radio makes and models.

## Core Architecture Pattern

### The Rosetta Stone Pattern

```
User Creates Meta Codeplug (app format)
    ↓
Contains: Channels, Zones, Systems, TalkGroups
    ↓
Export to Specific Radio Format
    ↓
Generate CSV for: Motorola CPS, Baofeng CHIRP, Kenwood KPG, etc.
```

**Key Principle:** Separate the **data** (what channels/frequencies you want) from the **format** (how each radio expects to receive that data).

### Abstraction Layers

1. **Data Layer**: Models store canonical radio programming data
2. **Logic Layer**: Services handle business logic and validations
3. **Export Layer**: Formatters/exporters transform data into radio-specific CSV formats
4. **Presentation Layer**: Hotwire/Turbo for dynamic UI

---

## Technology Stack

### Backend
- **Ruby on Rails 8** - Latest stable version
- **Ruby 3.x** - Version specified in `.ruby-version`
- **MariaDB** - Primary database (database-agnostic design, no PostgreSQL dependencies)
- **Solid Queue** - Background jobs (Rails 8 default)
- **Solid Cache** - Caching (Rails 8 default)

### Frontend
- **Hotwire (Turbo + Stimulus)** - Modern Rails frontend framework
- **Bootstrap 5** - CSS framework for UI components
- **esbuild** - JavaScript bundling (fast, modern)
- **Importmap** - JavaScript module management

### Testing
- **Minitest** - Rails default testing framework
- **Capybara** - System/integration testing
- **Selenium/Browser Driver** - For system tests

### Code Quality
- **RuboCop** - Ruby linter and style enforcer (run with -a to auto-fix)
- **Brakeman** - Security vulnerability scanner (already in bin/)

### Deployment
- **Kamal** - Modern deployment tool
- **Docker** - Containerization

---

## Design Principles

### 1. Test-Driven Development (TDD)

**Strict TDD Workflow:**
```
1. Write failing test
2. Run test (verify it fails)
3. Write minimum code to pass
4. Run test (verify it passes)
5. Refactor
6. Repeat
```

**Rules:**
- NO code without tests
- NO PRs with failing tests
- ALL tests must pass before PR creation
- Follow Red-Green-Refactor cycle

### 2. Rails Best Practices

- **Convention over Configuration** - Follow Rails conventions
- **Fat Models, Skinny Controllers** - Business logic in models/services, not controllers
- **RESTful Routes** - Use standard REST actions where possible
- **DRY (Don't Repeat Yourself)** - Extract common patterns
- **KISS (Keep It Simple, Stupid)** - Simple solutions over clever ones

### 3. Code Organization Patterns

#### Service Objects
Use for complex business logic that doesn't fit cleanly in a model:

```ruby
# app/services/codeplug_exporter.rb
class CodeplugExporter
  def initialize(codeplug, radio_model)
    @codeplug = codeplug
    @radio_model = radio_model
  end

  def export
    # Complex export logic here
  end
end
```

**When to use:**
- Multi-step operations
- Orchestrating multiple models
- External API interactions
- File generation (CSV exports)

#### Form Objects
Use for complex forms that span multiple models:

```ruby
# app/forms/channel_builder_form.rb
class ChannelBuilderForm
  include ActiveModel::Model
  # Handle channel + system_talkgroup selection
end
```

**When to use:**
- Forms that create/update multiple models
- Complex validation logic
- Non-RESTful form flows

#### Concerns
Use for shared behavior across models:

```ruby
# app/models/concerns/nameable.rb
module Nameable
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true
  end
end
```

**When to use:**
- Shared validations
- Common query scopes
- Reusable model behavior

#### Query Objects
Use for complex database queries:

```ruby
# app/queries/available_talkgroups_query.rb
class AvailableTalkgroupsQuery
  def initialize(system)
    @system = system
  end

  def call
    # Complex query to find available talkgroups
  end
end
```

**When to use:**
- Complex joins
- Filtering logic
- Reusable queries across controllers

### 4. Testing Strategy

#### Model Tests (`test/models/`)
- Test validations
- Test associations
- Test scopes
- Test instance methods
- Test class methods

```ruby
# test/models/channel_test.rb
class ChannelTest < ActiveSupport::TestCase
  test "should not save channel without name" do
    channel = Channel.new
    assert_not channel.save
  end

  test "should belong to codeplug" do
    channel = channels(:one)
    assert_respond_to channel, :codeplug
  end
end
```

#### Controller Tests (`test/controllers/`)
Focus on:
- HTTP responses
- Redirects
- Flash messages
- Authorization
- Parameter handling

```ruby
# test/controllers/channels_controller_test.rb
class ChannelsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get channels_url
    assert_response :success
  end

  test "should create channel" do
    assert_difference('Channel.count') do
      post channels_url, params: { channel: { name: "Test" } }
    end
    assert_redirected_to channel_url(Channel.last)
  end
end
```

#### System Tests (`test/system/`)
End-to-end user workflows using Capybara:

```ruby
# test/system/channel_creation_test.rb
class ChannelCreationTest < ApplicationSystemTestCase
  test "user creates a new channel" do
    visit new_channel_path

    fill_in "Name", with: "Local Repeater"
    select "W4ABC Repeater", from: "System"
    click_on "Create Channel"

    assert_text "Channel was successfully created"
  end
end
```

**System test focus:**
- Complete user workflows
- JavaScript interactions
- Form submissions
- Navigation flows

#### Service/Helper Tests
- Test complex business logic
- Test formatters/exporters
- Test helper methods

### 5. File Upload Handling (CSV)

**No Active Storage needed** - CSVs are transient:

**Import Flow:**
```ruby
# Controller receives uploaded file
def import
  csv_file = params[:file]
  result = CsvImporter.new(csv_file).import
  # File is processed and discarded
end
```

**Export Flow:**
```ruby
# Generate CSV on-the-fly
def export
  csv_data = CodeplugExporter.new(@codeplug, @radio_model).to_csv
  send_data csv_data, filename: "codeplug.csv", type: "text/csv"
end
```

**Key Points:**
- Files never saved to disk/storage
- Processed in memory
- Streamed to user on export
- No cleanup needed

---

## CI/CD & Quality Gates

### GitHub Actions Workflow

**Pre-PR Requirements:**
1. All tests must pass (unit, integration, system)
2. RuboCop violations must be resolved (run rubocop -a to auto-fix)
3. Brakeman security scan must pass

**Automated Checks:**
```yaml
# .github/workflows/ci.yml
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - Run database setup
      - Run rails test (all tests)
      - Run rubocop -a
      - Run brakeman
```

**Rules:**
- Breaking tests MUST be fixed before PR, even if outside commit scope
- No exceptions to passing tests requirement
- CI must be green before merge

### Local Development Workflow

**Before creating PR:**
```bash
# Run full test suite
rails test
rails test:system

# Auto-fix and check code style
rubocop -a

# Check security
brakeman

# All must pass before proceeding
```

**Pre-commit Hook (Optional but Recommended):**
```bash
#!/bin/bash
# .git/hooks/pre-commit
rails test && rubocop -a
```

---

## Data Flow Examples

### Creating a Channel

```
User Input (Form)
    ↓
Controller validates params
    ↓
Service Object (ChannelBuilder)
    ↓
Creates Channel + Associates SystemTalkGroup
    ↓
Creates ChannelZone with position
    ↓
Validates against System capabilities
    ↓
Saves to database
    ↓
Turbo stream updates UI
```

### Exporting a Codeplug

```
User selects RadioModel + Codeplug
    ↓
Controller calls CodeplugExporter service
    ↓
Service fetches CodeplugLayout for RadioModel
    ↓
Iterates through Zones (respecting max_channels_per_zone)
    ↓
For each Channel, pulls System data
    ↓
Maps to CSV columns per layout_definition
    ↓
Generates CSV string
    ↓
Streams to user as download
```

### Zone Splitting on Export

```
Zone has 30 channels
    ↓
Target RadioModel.max_channels_per_zone = 16
    ↓
Service detects overflow
    ↓
Prompts user: "Split 30 channels across 2 zones?"
    ↓
User chooses split strategy (16/14 or 15/15)
    ↓
Generates 2 zones in CSV output
    ↓
Maintains channel order via position
```

---

## Database Design Philosophy

### Polymorphic Associations
Used for mode-specific system attributes:

```ruby
class System < ApplicationRecord
  belongs_to :mode_detail, polymorphic: true
end

class DmrModeDetail < ApplicationRecord
  has_one :system, as: :mode_detail
end
```

**Why:** Keeps mode-specific attributes in separate tables, clean schema, easy to extend with new modes.

### Join Tables with Attributes
Used when relationship needs metadata:

```ruby
class ChannelZone < ApplicationRecord
  belongs_to :channel
  belongs_to :zone
  # position attribute stores channel order
end
```

**Why:** Many-to-many with additional data (position, timeslot, etc.)

### Database Agnostic
- No PostgreSQL-specific features (jsonb, array columns, etc.)
- Use Rails serialization for arrays/JSON
- Works with MariaDB, MySQL, PostgreSQL, SQLite

---

## Security Considerations

### Authentication
- Rails 8 built-in authentication
- Session-based (cookies)
- Password hashing via bcrypt

### Authorization
- User owns their Codeplugs
- Systems/Networks/TalkGroups are shared (public read)
- Codeplugs have public/private flag

### Input Validation
- Strong parameters in controllers
- Model validations
- CSV parsing with error handling
- Prevent SQL injection (use ActiveRecord)
- Prevent XSS (Rails auto-escaping)

### File Upload Security
- Validate CSV format
- Limit file size
- Parse safely (CSV library)
- No file execution

---

## Performance Considerations

### Database Indexes
See MODELS.md for comprehensive index list.

**Key indexes:**
- Foreign keys
- User lookup (email)
- Geographic queries (lat/lng)
- Join table combinations

### Caching
- Fragment caching for expensive views
- Solid Cache (Rails 8 default)
- Cache system/network data (rarely changes)

### N+1 Query Prevention
- Use `includes` for associations
- Bullet gem in development (optional)
- Monitor query counts in logs

### Background Jobs
- CSV generation for large codeplugs
- Bulk operations
- Email notifications
- Use Solid Queue (Rails 8 default)

---

## Frontend Architecture

### Hotwire/Turbo

**Turbo Drive:**
- Automatic page navigation
- Maintains speed of SPA

**Turbo Frames:**
- Partial page updates
- Independent frame navigation

```erb
<turbo-frame id="channel_form">
  <%= render "form" %>
</turbo-frame>
```

**Turbo Streams:**
- Real-time updates
- CRUD operations without full page reload

```ruby
# controller
respond_to do |format|
  format.turbo_stream
  format.html
end
```

### Stimulus Controllers

**Minimal JavaScript:**
- Form enhancements
- Dynamic field showing/hiding
- CSV field picker interface
- Drag-and-drop for channel reordering

```javascript
// app/javascript/controllers/channel_reorder_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Initialize drag-and-drop
  }
}
```

### Bootstrap Integration

**Components:**
- Forms (form-control, form-select)
- Buttons (btn, btn-primary)
- Cards (card, card-body)
- Navigation (navbar, nav)
- Modals for confirmations
- Toasts for flash messages

**Customization:**
- Override Bootstrap variables if needed
- Keep custom CSS minimal
- Use Bootstrap utilities

---

## Deployment Architecture

### Kamal Deployment

**Infrastructure:**
- Docker containers
- Zero-downtime deploys
- Health checks
- Automatic rollback

**Configuration:**
- `config/deploy.yml`
- Environment variables
- Database configuration
- Asset compilation

**Process:**
```bash
kamal setup    # First-time setup
kamal deploy   # Deploy updates
kamal app logs # View logs
```

---

## Future Architecture Considerations

### API Layer
When needed, add:
- JSON API endpoints
- Token authentication
- API versioning
- Rate limiting

### Real-time Features
If needed:
- Action Cable for live updates
- Turbo Streams over WebSocket
- Shared codeplug editing

### Mobile Support
- Responsive design (Bootstrap handles this)
- Progressive Web App (PWA) capabilities
- Touch-friendly interfaces

### Advanced Export Features
- Background job for large exports
- Export queue management
- Email delivery of completed exports
- Export templates/favorites

---

## Naming Conventions

### Models
- Singular, PascalCase: `RadioModel`, `SystemTalkGroup`

### Controllers
- Plural, PascalCase: `ChannelsController`, `CodeplugsController`

### Services
- Noun or Verb, descriptive: `CodeplugExporter`, `CsvImporter`

### Tests
- Match file being tested + `_test.rb`: `channel_test.rb`, `channels_controller_test.rb`

### Database Tables
- Plural, snake_case: `radio_models`, `system_talkgroups`

### Routes
- RESTful where possible
- Plural resource names

```ruby
resources :codeplugs do
  member do
    get :export
  end
end
```

---

## Documentation Standards

### Code Comments
- Explain WHY, not WHAT
- Document complex algorithms
- Note edge cases
- Reference external docs (radio specs)

### README
- Project overview
- Setup instructions
- Testing instructions
- Deployment guide

### CHANGELOG (future)
- Semantic versioning
- Feature additions
- Bug fixes
- Breaking changes

---

## Error Handling

### User-Facing Errors
- Clear, actionable error messages
- Field-level validation errors
- Form inline errors (Bootstrap styling)

### System Errors
- Log to Rails logger
- Notify admins (future: error tracking service)
- Graceful degradation
- Helpful error pages (400, 404, 500)

### CSV Errors
- Validate format before processing
- Report line-by-line errors
- Allow partial imports with warnings
- Provide example/template files

---

## Accessibility

### Standards
- Semantic HTML
- ARIA labels where needed
- Keyboard navigation
- Color contrast (Bootstrap defaults)
- Form labels and instructions

### Testing
- Manual keyboard testing
- Screen reader testing (when possible)
- Automated accessibility checks (future)

---

## Internationalization (i18n)

**Not a priority now, but architecture supports it:**
- Use I18n for all user-facing text
- Extract strings to locale files
- Future: Support multiple languages
- Store user locale preference

---

## Monitoring & Logging

### Development
- Rails logger (verbose)
- Detailed error traces
- Query logging

### Production
- Rails logger (info level)
- Exception tracking (future: Sentry, Rollbar)
- Performance monitoring (future: Scout, Skylight)
- Uptime monitoring

---

## Version Control

### Git Workflow
- Feature branches from main
- PR required for merge
- Meaningful commit messages
- Squash merge for clean history

### Commit Messages
```
Add channel reordering feature

- Add drag-and-drop with Stimulus
- Update position on drop
- Add system tests for reordering

Closes #123
```

### Branch Naming
- `feature/channel-reordering`
- `fix/tone-validation-bug`
- `refactor/codeplug-exporter`

---

## Development Environment

### Required Tools
- Ruby (version in `.ruby-version`)
- Node.js (version in `.node-version`)
- MariaDB/MySQL
- Git
- Docker (for Kamal deployment)

### Recommended Tools
- VS Code with Ruby LSP
- TablePlus or similar DB GUI
- Postman (for future API testing)

### Setup Commands
```bash
bin/setup           # Initial setup
bin/rails db:setup  # Database setup
bin/dev             # Start development servers
bin/rails test      # Run tests
```

---

## Code Review Guidelines

### What to Look For
- Tests present and passing
- Follows Rails conventions
- No RuboCop violations (after running rubocop -a)
- Clear, readable code
- Proper error handling
- Security considerations
- Performance implications

### PR Description Should Include
- What changed and why
- Testing performed
- Screenshots (for UI changes)
- Migration details (if applicable)
- Breaking changes noted

---

This architecture is designed to be:
- **Scalable**: Easy to add new radio models and modes
- **Maintainable**: Clear patterns and conventions
- **Testable**: TDD from the start
- **Performant**: Efficient queries and caching
- **Secure**: Rails defaults + validation
- **User-Friendly**: Modern UI with Hotwire

The architecture will evolve as the application grows, but these foundational principles guide all development decisions.
