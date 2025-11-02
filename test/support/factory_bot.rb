# Factory Bot configuration for tests
# This file ensures Factory Bot is properly configured in the test environment

# Ensure factories are loaded from test/factories
# Note: FactoryBot.find_definitions is called automatically by Rails,
# so we don't need to call it explicitly here
FactoryBot.definition_file_paths = [ "test/factories" ]
