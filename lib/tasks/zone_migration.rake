namespace :zones do
  desc "Analyze existing zone and channel data for migration"
  task analyze: :environment do
    puts "=" * 60
    puts "Zone Data Analysis"
    puts "=" * 60
    puts

    # Count zones
    total_zones = Zone.count
    legacy_zones = Zone.where.not(codeplug_id: nil).count
    standalone_zones = Zone.where(codeplug_id: nil).count

    puts "ZONES:"
    puts "  Total zones: #{total_zones}"
    puts "  Legacy zones (with codeplug_id): #{legacy_zones}"
    puts "  Standalone zones (without codeplug_id): #{standalone_zones}"
    puts

    # Zones per codeplug
    puts "ZONES PER CODEPLUG (Legacy):"
    Zone.where.not(codeplug_id: nil).group(:codeplug_id).count.each do |codeplug_id, count|
      codeplug = Codeplug.find_by(id: codeplug_id)
      puts "  Codeplug '#{codeplug&.name || 'Unknown'}' (ID: #{codeplug_id}): #{count} zones"
    end
    puts

    # Channels per zone
    puts "CHANNELS PER ZONE (via ChannelZone):"
    Zone.includes(:channel_zones).find_each do |zone|
      channel_count = zone.channel_zones.count
      next if channel_count == 0

      puts "  Zone '#{zone.name}' (ID: #{zone.id}): #{channel_count} channels"
    end
    puts

    # Analyze system types in zones
    puts "SYSTEM TYPES IN ZONES:"
    Zone.includes(channels: :system).find_each do |zone|
      systems = zone.channels.map(&:system).compact.uniq
      next if systems.empty?

      analog_count = systems.count { |s| s.mode == "analog" }
      digital_count = systems.count { |s| s.mode != "analog" }
      puts "  Zone '#{zone.name}': #{analog_count} analog, #{digital_count} digital systems"
    end
    puts

    # Check for zones that already have ZoneSystem records
    puts "ZONES WITH EXISTING ZONE_SYSTEM RECORDS:"
    Zone.includes(:zone_systems).find_each do |zone|
      next if zone.zone_systems.empty?

      puts "  Zone '#{zone.name}' (ID: #{zone.id}): #{zone.zone_systems.count} ZoneSystem records"
    end
    puts

    # Check for zones that already have CodeplugZone records
    puts "ZONES WITH EXISTING CODEPLUG_ZONE RECORDS:"
    Zone.includes(:codeplug_zones).find_each do |zone|
      next if zone.codeplug_zones.empty?

      puts "  Zone '#{zone.name}' (ID: #{zone.id}): #{zone.codeplug_zones.count} CodeplugZone records"
    end
    puts

    # Edge cases
    puts "EDGE CASES:"
    empty_zones = Zone.left_joins(:channel_zones).where(channel_zones: { id: nil }).count
    puts "  Zones with no channels: #{empty_zones}"

    zones_without_user = Zone.where(user_id: nil).count
    puts "  Zones without user_id: #{zones_without_user}"
    puts

    puts "=" * 60
    puts "Analysis Complete"
    puts "=" * 60
  end

  desc "Migrate legacy zone data to new architecture"
  task migrate: :environment do
    puts "=" * 60
    puts "Zone Data Migration"
    puts "=" * 60
    puts

    # Safety check for production
    if Rails.env.production?
      print "WARNING: You are running in PRODUCTION. Continue? (yes/no): "
      response = $stdin.gets.chomp
      unless response.downcase == "yes"
        puts "Migration aborted."
        exit
      end
    end

    # Find legacy zones (zones with codeplug_id set)
    legacy_zones = Zone.where.not(codeplug_id: nil)
    total = legacy_zones.count

    if total == 0
      puts "No legacy zones found to migrate."
      puts "Migration complete."
      exit
    end

    puts "Found #{total} legacy zones to migrate."
    puts

    migrated_count = 0
    skipped_count = 0
    error_count = 0

    legacy_zones.find_each.with_index do |zone, index|
      print "Migrating zone #{index + 1}/#{total}: '#{zone.name}' (ID: #{zone.id})... "

      begin
        ActiveRecord::Base.transaction do
          # Phase A: Create CodeplugZone if it doesn't exist
          unless CodeplugZone.exists?(codeplug_id: zone.codeplug_id, zone_id: zone.id)
            # Find the next available position
            max_position = CodeplugZone.where(codeplug_id: zone.codeplug_id).maximum(:position) || 0
            CodeplugZone.create!(
              codeplug_id: zone.codeplug_id,
              zone_id: zone.id,
              position: max_position + 1
            )
          end

          # Phase B: Build ZoneSystem records from channels
          # Get unique systems from this zone's channels
          channel_systems = zone.channels.includes(:system).map(&:system).compact.uniq

          channel_systems.each_with_index do |system, sys_index|
            # Skip if ZoneSystem already exists
            next if ZoneSystem.exists?(zone_id: zone.id, system_id: system.id)

            # Find the next available position
            max_position = ZoneSystem.where(zone_id: zone.id).maximum(:position) || 0
            zone_system = ZoneSystem.create!(
              zone_id: zone.id,
              system_id: system.id,
              position: max_position + 1
            )

            # Phase C: For digital systems, create ZoneSystemTalkGroup records
            if %w[dmr p25 nxdn].include?(system.mode)
              # Get unique SystemTalkGroups from this zone's channels for this system
              system_talk_groups = zone.channels
                .where(system_id: system.id)
                .where.not(system_talk_group_id: nil)
                .includes(:system_talk_group)
                .map(&:system_talk_group)
                .compact.uniq

              system_talk_groups.each do |stg|
                # Skip if ZoneSystemTalkGroup already exists
                next if ZoneSystemTalkGroup.exists?(zone_system_id: zone_system.id, system_talk_group_id: stg.id)

                ZoneSystemTalkGroup.create!(
                  zone_system_id: zone_system.id,
                  system_talk_group_id: stg.id
                )
              end
            end
          end
        end

        puts "OK"
        migrated_count += 1
      rescue ActiveRecord::RecordInvalid => e
        puts "ERROR: #{e.message}"
        error_count += 1
      rescue StandardError => e
        puts "ERROR: #{e.message}"
        error_count += 1
      end
    end

    puts
    puts "=" * 60
    puts "Migration Summary"
    puts "=" * 60
    puts "  Migrated: #{migrated_count}"
    puts "  Skipped: #{skipped_count}"
    puts "  Errors: #{error_count}"
    puts

    if error_count > 0
      puts "WARNING: Some zones failed to migrate. Review errors above."
    else
      puts "Migration completed successfully!"
    end
  end

  desc "Verify data integrity after migration"
  task verify: :environment do
    puts "=" * 60
    puts "Zone Data Verification"
    puts "=" * 60
    puts

    errors = []

    # Check 1: All zones have user_id
    zones_without_user = Zone.where(user_id: nil).count
    if zones_without_user > 0
      errors << "#{zones_without_user} zones without user_id"
    end
    puts "Zones without user_id: #{zones_without_user} #{zones_without_user == 0 ? '✓' : '✗'}"

    # Check 2: All legacy zones have CodeplugZone association
    legacy_zones = Zone.where.not(codeplug_id: nil)
    legacy_without_codeplug_zone = legacy_zones.left_joins(:codeplug_zones).where(codeplug_zones: { id: nil }).count
    if legacy_without_codeplug_zone > 0
      errors << "#{legacy_without_codeplug_zone} legacy zones without CodeplugZone"
    end
    puts "Legacy zones without CodeplugZone: #{legacy_without_codeplug_zone} #{legacy_without_codeplug_zone == 0 ? '✓' : '✗'}"

    # Check 3: All systems from channels are represented in ZoneSystem
    zones_missing_systems = 0
    Zone.includes(:channels, :zone_systems).find_each do |zone|
      channel_system_ids = zone.channels.pluck(:system_id).uniq
      zone_system_ids = zone.zone_systems.pluck(:system_id)
      missing = channel_system_ids - zone_system_ids
      if missing.any?
        zones_missing_systems += 1
        puts "  Zone '#{zone.name}' missing ZoneSystem for systems: #{missing.join(', ')}"
      end
    end
    if zones_missing_systems > 0
      errors << "#{zones_missing_systems} zones missing ZoneSystem records"
    end
    puts "Zones with missing ZoneSystem records: #{zones_missing_systems} #{zones_missing_systems == 0 ? '✓' : '✗'}"

    # Check 4: All talkgroups from digital channels are in ZoneSystemTalkGroup
    zones_missing_talkgroups = 0
    Zone.includes(channels: :system_talk_group, zone_systems: :zone_system_talkgroups).find_each do |zone|
      zone.zone_systems.each do |zone_system|
        next unless %w[dmr p25 nxdn].include?(zone_system.system.mode)

        channel_stg_ids = zone.channels
          .where(system_id: zone_system.system_id)
          .where.not(system_talk_group_id: nil)
          .pluck(:system_talk_group_id).uniq

        zone_stg_ids = zone_system.zone_system_talkgroups.pluck(:system_talk_group_id)
        missing = channel_stg_ids - zone_stg_ids

        if missing.any?
          zones_missing_talkgroups += 1
          puts "  Zone '#{zone.name}' / System '#{zone_system.system.name}' missing talkgroups: #{missing.join(', ')}"
        end
      end
    end
    if zones_missing_talkgroups > 0
      errors << "#{zones_missing_talkgroups} zone-systems missing ZoneSystemTalkGroup records"
    end
    puts "Zone-systems with missing ZoneSystemTalkGroup: #{zones_missing_talkgroups} #{zones_missing_talkgroups == 0 ? '✓' : '✗'}"

    # Summary
    puts
    puts "=" * 60
    if errors.empty?
      puts "Verification PASSED - All checks passed!"
    else
      puts "Verification FAILED - #{errors.count} issue(s) found:"
      errors.each { |e| puts "  - #{e}" }
    end
    puts "=" * 60
  end

  desc "Rollback migration (restore codeplug_id, remove new associations)"
  task rollback: :environment do
    puts "=" * 60
    puts "Zone Data Rollback"
    puts "=" * 60
    puts

    # Safety check for production
    if Rails.env.production?
      print "WARNING: You are running ROLLBACK in PRODUCTION. This will delete ZoneSystem and ZoneSystemTalkGroup records. Continue? (yes/no): "
      response = $stdin.gets.chomp
      unless response.downcase == "yes"
        puts "Rollback aborted."
        exit
      end
    end

    puts "This will:"
    puts "  1. Delete all ZoneSystemTalkGroup records"
    puts "  2. Delete all ZoneSystem records"
    puts "  3. Delete all CodeplugZone records for legacy zones"
    puts

    print "Are you sure you want to continue? (yes/no): "
    response = $stdin.gets.chomp
    unless response.downcase == "yes"
      puts "Rollback aborted."
      exit
    end

    puts
    puts "Starting rollback..."

    ActiveRecord::Base.transaction do
      # Delete ZoneSystemTalkGroup records
      zstg_count = ZoneSystemTalkGroup.count
      ZoneSystemTalkGroup.delete_all
      puts "  Deleted #{zstg_count} ZoneSystemTalkGroup records"

      # Delete ZoneSystem records
      zs_count = ZoneSystem.count
      ZoneSystem.delete_all
      puts "  Deleted #{zs_count} ZoneSystem records"

      # Delete CodeplugZone records for legacy zones (zones that have codeplug_id)
      legacy_zone_ids = Zone.where.not(codeplug_id: nil).pluck(:id)
      cz_count = CodeplugZone.where(zone_id: legacy_zone_ids).count
      CodeplugZone.where(zone_id: legacy_zone_ids).delete_all
      puts "  Deleted #{cz_count} CodeplugZone records for legacy zones"
    end

    puts
    puts "=" * 60
    puts "Rollback Complete"
    puts "=" * 60
  end

  desc "Clear codeplug_id from migrated zones (run after verification)"
  task clear_legacy_codeplug_ids: :environment do
    puts "=" * 60
    puts "Clear Legacy codeplug_id Values"
    puts "=" * 60
    puts

    legacy_zones = Zone.where.not(codeplug_id: nil)
    count = legacy_zones.count

    if count == 0
      puts "No zones with codeplug_id found."
      exit
    end

    puts "Found #{count} zones with codeplug_id set."
    puts "This will clear the codeplug_id field from these zones."
    puts "The CodeplugZone associations will remain intact."
    puts

    print "Continue? (yes/no): "
    response = $stdin.gets.chomp
    unless response.downcase == "yes"
      puts "Aborted."
      exit
    end

    updated = legacy_zones.update_all(codeplug_id: nil)
    puts "Cleared codeplug_id from #{updated} zones."
    puts
    puts "=" * 60
    puts "Complete"
    puts "=" * 60
  end
end
