# Codeplug Application

A web-based tool for managing two-way radio programming data. Create a single canonical codeplug and export it to multiple radio-specific CSV formats.

## Overview

The Codeplug Application serves as a "Rosetta Stone" for radio programming files (codeplugs). Users create their radio configuration once in a universal format, then export it to CSV files compatible with dozens of different radio makes and models - each with their own programming software and data layout requirements.

**Key Features:**
- **Universal Codeplug Format**: Define channels, zones, systems, and talkgroups once
- **Multi-Radio Export**: Generate CSV files for Motorola, Baofeng, Kenwood, and more
- **Analog & Digital Support**: Handle analog, DMR, P25, NXDN, and other modes
- **Shared Resources**: Community-maintained database of repeaters and talkgroups
- **Custom Layouts**: Create and share CSV export formats for unsupported radios

## Architecture

- **Backend**: Ruby on Rails 8 with PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus) with Bootstrap 5
- **Testing**: Minitest with Capybara for system tests
- **Deployment**: Kamal with Docker
- **Development**: TDD (Test-Driven Development) workflow

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architectural decisions and patterns.

## Data Model

The application manages several key entities:

- **Codeplugs**: User's complete radio configuration
- **Zones**: Standalone templates defining systems and talkgroups (public/private)
- **Channels**: Generated from zones or manually created
- **Systems**: Repeater/simplex frequencies with technical specs (shared resource)
- **TalkGroups**: Digital radio talkgroup definitions organized by networks
- **Radio Models**: Radio hardware specifications and capabilities
- **Codeplug Layouts**: CSV export format definitions for specific radios

### Zone Architecture

Zones use a template-based approach:
- Zones are **standalone entities** owned by users (not embedded in codeplugs)
- Zones can be **public** (shareable) or **private**
- Zones define which **systems** and **talkgroups** to include
- Channels are **generated** from zones when the user is ready
- Generated channels can be **customized** (changes persist until regeneration)

See [docs/MODELS.md](docs/MODELS.md) for complete data model documentation.

## Requirements

- **Ruby**: See `.ruby-version` (Ruby 3.x)
- **Node.js**: See `.node-version` (for esbuild)
- **Database**: PostgreSQL (version 12 or higher recommended)
- **Bundler**: Latest version
- **Yarn**: Latest version

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/livitup/codeplug_app.git
cd codeplug_app
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies
yarn install
```

### 3. Configure Database

```bash
# Database configuration is already set up for PostgreSQL
# Edit config/database.yml if you need custom settings
# Default assumes PostgreSQL on localhost with standard settings
```

### 4. Setup Database

```bash
# Create database, run migrations, and seed initial data
bin/rails db:setup
```

**Seed User Credentials (Development):**
- Email: `dev@example.com`
- Password: `password123`

The seed data creates:
- 1 development user account
- 10 radio manufacturers
- 10 realistic radio models with specifications
- Sample networks (Brandmeister, TGIF, P25 Network)
- Sample systems (analog and DMR repeaters)
- Sample talkgroups
- Sample zones with systems and talkgroups
- Sample codeplug with generated channels

### 5. Start Development Server

```bash
# Starts Rails server, CSS bundler, and JS bundler
bin/dev
```

The application will be available at `http://localhost:3000`

## Development Workflow

### Test-Driven Development (TDD)

This project follows **strict TDD**. All features and bug fixes must:

1. Start with failing tests
2. Implement minimum code to pass
3. Refactor while keeping tests green
4. Ensure ALL tests pass before committing

**No exceptions.**

### Running Tests

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/channel_test.rb

# Run system tests
rails test:system

# Run all tests including system tests
rails test:all
```

### Code Quality Checks

```bash
# Run RuboCop (auto-fix and check style/lint)
rubocop -a

# Run Brakeman (security scanner)
brakeman
```

### Before Creating a Pull Request

**ALL of the following must pass:**

```bash
# 1. Run full test suite
rails test:all

# 2. Auto-fix and check code style
rubocop -a

# 3. Check security
brakeman
```

**Important:** If any test fails (even if unrelated to your changes), you MUST fix it before creating a PR. No exceptions.

## Project Structure

```
app/
├── controllers/      # HTTP request handling
├── models/          # Data models and business logic
├── views/           # HTML templates (ERB)
├── javascript/      # Stimulus controllers and JS
├── assets/          # Stylesheets (Bootstrap SCSS)
├── services/        # Business logic (exporters, importers, etc.)
├── forms/           # Form objects for complex forms
└── queries/         # Complex database queries

test/
├── models/          # Model unit tests
├── controllers/     # Controller integration tests
├── system/          # End-to-end browser tests (Capybara)
├── services/        # Service object tests
└── fixtures/        # Test data

docs/
├── MODELS.md        # Complete data model documentation
├── ARCHITECTURE.md  # Architecture decisions and patterns
└── CLAUDE.md        # AI assistant instructions (optional)

config/
├── database.yml     # Database configuration
├── routes.rb        # URL routing
└── deploy.yml       # Kamal deployment config
```

## Common Tasks

### Creating a New Model

```bash
# Generate model with migrations
rails generate model Channel name:string codeplug:references system:references

# Run TDD workflow
# 1. Write tests in test/models/channel_test.rb
# 2. Run: rails test test/models/channel_test.rb
# 3. Implement model logic
# 4. Repeat until green
```

### Creating a New Controller

```bash
# Generate controller with views
rails generate controller Channels index show new create edit update destroy

# Write controller tests first
# test/controllers/channels_controller_test.rb

# Write system tests for user workflows
# test/system/channel_management_test.rb
```

### Creating a Service Object

```bash
# Create service in app/services/
touch app/services/codeplug_exporter.rb

# Create test first
touch test/services/codeplug_exporter_test.rb

# Follow TDD workflow
```

### Database Migrations

```bash
# Create migration
rails generate migration AddBandwidthToSystems bandwidth:string

# Edit migration file in db/migrate/

# Run migration
rails db:migrate

# Rollback if needed
rails db:rollback
```

### Adding a New Digital Mode

1. Create mode detail model (polymorphic)
   ```bash
   rails generate model NxdnModeDetail ran:integer
   ```

2. Add mode to System enum
3. Update forms to show/hide mode-specific fields
4. Write tests for new mode
5. Update export logic to handle new mode

## User Workflows

### Creating Zones (Templates)

1. User registers/logs in
2. Navigates to "Zones" in the navigation menu
3. Creates a new Zone (name, optional long/short names)
4. Adds Systems to the zone (analog repeaters, DMR repeaters, etc.)
5. For digital systems, adds Talkgroups (with timeslot info)
6. Optionally marks the zone as "Public" to share with other users

### Creating a Codeplug

1. User creates a new Codeplug
2. Adds Zones to the codeplug (own zones or public zones from other users)
3. Reorders zones as desired using drag-and-drop
4. Clicks "Generate Channels" to create channels from the zone templates
5. Optionally customizes generated channels (name, power level, etc.)
6. Exports Codeplug for specific Radio Model

### Regenerating Channels

If you modify zones (add systems/talkgroups) after generating channels:
1. Navigate to the codeplug
2. Click "Regenerate Channels"
3. Confirm the regeneration (existing channels will be replaced)
4. New channels are generated from the updated zone templates
5. Any previous customizations will be lost

### Exporting to Radio Format

1. User selects Codeplug to export
2. Selects target Radio Model
3. System checks Zone sizes against radio limits
4. If needed, prompts for Zone split strategy
5. Generates CSV using CodeplugLayout for that radio
6. User downloads CSV file
7. User imports CSV into radio programming software

### Adding a New Radio Model

1. Admin/User creates Manufacturer (if needed)
2. Creates Radio Model with specs (zones, channels, name lengths)
3. Uses field picker interface to define CSV layout
4. Saves CodeplugLayout associated with Radio Model
5. Other users can now export to this radio format

## Deployment

### Using Kamal

```bash
# First-time setup
kamal setup

# Deploy updates
kamal deploy

# View logs
kamal app logs

# Rollback to previous version
kamal rollback
```

See `config/deploy.yml` for deployment configuration.

### Environment Variables

Required environment variables for production:

```bash
RAILS_MASTER_KEY=<from config/master.key>
DATABASE_URL=<production database connection string>
```

## Contributing

### Development Guidelines

1. **Test-Driven Development**: Write tests first, always
2. **Follow Rails Conventions**: Use Rails idioms and patterns
3. **Code Style**: Pass RuboCop checks (run with -a to auto-fix)
4. **Security**: Pass Brakeman checks
5. **Documentation**: Update docs for significant changes

### Pull Request Process

1. Create feature branch from `main`
2. Write failing tests for new feature/fix
3. Implement feature/fix following TDD
4. Ensure ALL tests pass (`rails test:all`)
5. Ensure RuboCop passes (`rubocop -a`)
6. Ensure Brakeman passes (`brakeman`)
7. Create PR with clear description
8. Address code review feedback
9. Squash merge to main after approval

### Commit Message Format

```
Add feature/fix description (present tense)

- Bullet points for details
- What changed and why
- Reference issue numbers

Closes #123
```

## Testing Philosophy

- **Unit Tests**: Test individual models, methods, validations
- **Integration Tests**: Test controller actions, request/response
- **System Tests**: Test complete user workflows with browser
- **All Tests Must Pass**: No failing tests allowed in PRs

## Troubleshooting

### Database Connection Issues

```bash
# Check database is running
# macOS with Homebrew:
brew services list | grep postgresql

# Linux:
systemctl status postgresql

# Verify credentials in config/database.yml
# Test connection manually
psql -U postgres -d codeplug_app_development
```

### Asset Compilation Issues

```bash
# Rebuild assets
rails assets:clobber
rails assets:precompile

# Or restart dev server
bin/dev
```

### Test Failures

```bash
# Reset test database
RAILS_ENV=test rails db:reset

# Re-run tests
rails test:all
```

### JavaScript Not Loading

```bash
# Reinstall node modules
rm -rf node_modules
yarn install

# Restart esbuild
bin/dev
```

## Documentation

- [Data Models Documentation](docs/MODELS.md) - Complete model specifications
- [Architecture Documentation](docs/ARCHITECTURE.md) - Design decisions and patterns
- [Rails Guides](https://guides.rubyonrails.org/) - Rails framework documentation
- [Hotwire Documentation](https://hotwired.dev/) - Turbo and Stimulus guides
- [Bootstrap Documentation](https://getbootstrap.com/) - UI component library

## Support

- **Issues**: Report bugs and request features via [GitHub Issues](https://github.com/livitup/codeplug_app/issues)
- **Discussions**: Ask questions in [GitHub Discussions](https://github.com/livitup/codeplug_app/discussions)

## License

[Add your license here]

## Acknowledgments

Built with:
- [Ruby on Rails](https://rubyonrails.org/)
- [Hotwire](https://hotwired.dev/)
- [Bootstrap](https://getbootstrap.com/)
- [Kamal](https://kamal-deploy.org/)

---

**Status**: Active Development

**Version**: 0.1.0 (Initial Development)

**Last Updated**: 2025-12-17
