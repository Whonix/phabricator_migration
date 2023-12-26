# frozen_string_literal: true

require 'debug'
require 'dotenv'
require 'minitest/autorun'
require 'minitest/pride'
require 'vcr'
require 'webmock'

require './lib/comment'
require './lib/discourse_migrator'
require './lib/formatter'
require './lib/issue'
require './lib/phabricator_parser'
require './lib/user'

Dotenv.load

PHAB_KEY = ENV['PHAB_KEY']
PHAB_HOST = ENV['PHAB_HOST']

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end
