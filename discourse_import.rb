# frozen_string_literal: true

require 'dotenv'
require 'debug'
require './lib/discourse_migrator'
Dotenv.load

migration_data = JSON.parse(File.read('discourse_migration_data.json'))
discourse_migrator = DiscourseMigrator.new(migration_data)
discourse_migrator.migrate_data
