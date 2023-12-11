# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'

class Issue
  attr_reader :title, :description, :id, :status, :impact, :phid

  def initialize(issue_data)
    @id = issue_data['id']
    @phid = issue_data['phid']
    @title = issue_data['title']
    @description = issue_data['description']
    @status = issue_data['status']
    @impact = issue_data['impact']
  end
end

class User
  attr_reader :username, :phid, :id

  def initialize(user_data)
    @id = user_data['id']
    @phid = user_data['phid']
    @username = user_data['fields']['username']
  end
end

class PhabricatorParser
  attr_reader :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def raw_issues
    uri = URI("https://#{PHAB_HOST}/api/maniphest.query")
    params = {
      "api.token": api_key
    }
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri).body
  end

  def raw_users(after)
    uri = URI("https://#{PHAB_HOST}/api/user.search")
    params = {
      "api.token": api_key
    }

    params['after'] = after if after && after != 'null'
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri).body
  end

  def parse_issues
    raw = raw_issues
    parsed = JSON.parse(raw)

    parsed['result'].map do |_id, issue|
      Issue.new(issue)
    end.compact
  end

  def parse_users
    users = []
    after = 'null'

    until after.nil?
      raw = raw_users(after)
      parsed = JSON.parse(raw)
      after = parsed['result']['cursor']['after']
      users << build_users(parsed['result']['data'])
    end
    users.compact.flatten
  end

  def build_users(json)
    json.map do |user|
      User.new(user)
    end
  end
end

# class DiscoursePoster
#   attr_reader :issues, :api_key
#
#   def initialize(issues, api_key)
#     @issues = issues
#     @api_key = api_key
#   end
#
#   def post_issues
#     issues.each do |issue|
#       uri = URI('https://forums.discourse.org/posts.json')
#       res = Net::HTTP.post_form(uri, 'title': issue.title, 'raw': issue.description, category: 8,
#                                      tags: %w[status_open_issue_todo phabricator_issue])
#       puts res.body if res.is_a?(Net::HTTPSuccess)
#     end
#
#     'Posting Completed'
#   end
# end

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

phabricator_issues = PhabricatorParser.new(PHAB_KEY).parse_issues
phabricator_users = PhabricatorParser.new(PHAB_KEY).parse_users

# TODO: Get "phabricator_transactions"
# Then create a large json payload of relevant data to post to discourse
# write it to a text file with all the data
# something like this
# [{issue_name: issue.name,
#   issue_id: issue.id,
#   issue_phid: issue.phid,
#   issue_title: issue.title,
#   issue_description: issue.description,
#   issue_user: {
#     username: user.username,
#     user_id: user.id,
#     user_phid: user.phid,
#   }
#   transactions: [{
#     puts the comments and transaction data here, linked to the user
#   },
#   {etc etc }]
#   }]
#
#   then have the DiscoursePoster read the file, and make an API call to discourse to create a topic for each issue with tags and such
#   make sure to slim this file down to only a few issues for testing...nuke them, then do it live
