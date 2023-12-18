# frozen_string_literal: true

require 'test_helper'

class PhabricatorParserTest < Minitest::Test
  def setup
    @parser = PhabricatorParser.new(PHAB_KEY)
  end

  def test_it_parses_issues
    VCR.use_cassette('phabricator_parser_test/parse_issues') do
      issues = @parser.parse_issues

      assert_equal issues.sample.class, Issue
      assert_equal issues.class, Array
    end
  end

  def test_it_parses_users
    VCR.use_cassette('phabricator_parser_test/parse_users') do
      users = @parser.parse_users

      assert_equal users.sample.class, User
      assert_equal users.class, Array
    end
  end

  def test_it_parses_transactions
    VCR.use_cassette('phabricator_parser_test/parse_transactions') do
      comments = @parser.parse_transactions

      assert_equal comments.sample.class, Comment
      assert_equal comments.class, Array
    end
  end
end
