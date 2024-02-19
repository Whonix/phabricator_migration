# frozen_string_literal: true

require './lib/comment'
require './lib/issue'
require './lib/phabricator_parser'
require './lib/user'
require './lib/formatter'

puts 'Please enter your Phabricator API key'
PHAB_KEY = gets.chomp

# puts 'Please enter your Discourse API key'
# DISCOURSE_KEY = gets.chomp

puts 'Please enter your Phabricator Host URI'
PHAB_HOST = gets.chomp

# puts 'Please enter your Discourse Host URI'
# DISCOURSE_HOST = gets.chomp

# puts 'Please enter your desired Discourse category ID to post your issues'
# CATEGORY_ID = gets.chomp

# puts 'Please enter your desired Tags for your Discourse topics as a comma seperated list'
# TAGS = gets.chomp

puts 'Parsing Phabricator issues...'
issues = PhabricatorParser.new(PHAB_KEY).parse_issues

puts 'Parsing Phabricator users...'
users = PhabricatorParser.new(PHAB_KEY).parse_users

puts 'Parsing Phabricator comments...'
comments = PhabricatorParser.new(PHAB_KEY).parse_transactions

puts 'Formatting Phabricator data...'
formatter = Formatter.new(issues, comments, users)
formatter.link_export_data

puts 'Writing migration data as JSON...'
formatter.write_file('./discourse_migration_data.json')
