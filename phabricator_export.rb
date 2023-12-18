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

issues = PhabricatorParser.new(PHAB_KEY).parse_issues

users = PhabricatorParser.new(PHAB_KEY).parse_users

comments = PhabricatorParser.new(PHAB_KEY).parse_transactions

formatter = Formatter.new(issues, comments, users)
formatter.format_data
formatter.write_file('./discourse_migration_data.json')

# TODO: have the DiscoursePoster read the file
# make an API call to discourse to create a topic and tags for issues
# make sure to slim this file down to only a few issues for testing...nuke them, then do it live
