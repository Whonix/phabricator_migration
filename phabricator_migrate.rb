# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'

PHAB_KEY = ARGV[0]
DISCOURSE_KEY = ARGV[1]

class Issue
  attr_reader :title, :description

  def initialize(issue_data)
    @title = issue_data['title']
    @description = issue_data['description']
  end
end

class PhabricatorParser
  attr_reader :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def get_raw_issues
    uri = URI('https://phabricator.whonix.org/api/maniphest.query')
    params = {
      "api.token": api_key,
      "status": 'status-open'
    }
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri).body
  end

  def parse_issues
    raw = get_raw_issues
    parsed = JSON.parse(raw)

    parsed['result'].map do |_id, issue|
      Issue.new(issue)
    end.compact
  end
end

class DiscoursePoster
  attr_reader :issues, :api_key

  def initialize(issues, api_key)
    @issues = issues
    @api_key = api_key
  end

  def post_issues
    issues.each do |issue|
      uri = URI('https://forums.discourse.org/posts.json')
      res = Net::HTTP.post_form(uri, 'title': issue.title, 'raw': issue.description, category: 8,
                                     tags: %w[status_open_issue_todo phabricator_issue])
      puts res.body if res.is_a?(Net::HTTPSuccess)
    end

    'Posting Completed'
  end
end

puts "Please enter your Phabricator API key"
PHAB_KEY = gets.chomp

puts "Please enter your Discourse API key"
DISCOURSE_KEY = gets.chomp

puts "Please enter your Phabricator Host URI"
PHAB_HOST = gets.chomp

puts "Please enter your Discourse Host URI"
DISCOURSE_HOST = gets.chomp

puts "Please enter your desired Discourse category ID to post your issues"
CATEGORY_ID = gets.chomp

puts "Please enter your desired Tags for your Discourse topics as a comma seperated list"
TAGS = gets.chomp

issues = PhabricatorParser.new(PHAB_KEY).parse_issues
DiscoursePoster.new(issues, DISCOURSE_KEY).post_issues
