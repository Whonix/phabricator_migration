# frozen_string_literal: true

require 'test_helper'

class DiscourseMigratorTest < Minitest::Test
  def setup
    migration_data = JSON.parse(File.read('test/data/test_migration_data.json'))
    @discourse_migrator = DiscourseMigrator.new(migration_data, './test/logs/test_migration.log')
    debugger
  end

  def test_it_exists_with_data_attribute
    # assert_equal @discourse_migrator.data, @migration_data
  end

  def test_it_migrates_data
    skip
    # iterate through all tasks
    # create a discourse post for te past
    # tag the issue
    # log it
  end

  def test_it_creates_replies
    skip
    # iterate through all task comments
    # create a discourse doccment for te past
    # log it
  end
end
