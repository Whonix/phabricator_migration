# frozen_string_literal: true

require 'debug'
require 'dotenv'
require 'minitest/autorun'
require 'minitest/pride'
require 'vcr'
require 'webmock'

require './lib/comment'
require './lib/user'
require './lib/issue'
require './lib/phabricator_parser'

Dotenv.load

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end
