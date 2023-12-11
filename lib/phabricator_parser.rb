# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

class PhabricatorParser
  attr_reader :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def raw_issues
    uri = URI("https://#{PHAB_HOST}/api/maniphest.query")
    params = {
      'api.token': api_key
    }
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri).body
  end

  def raw_users(after)
    uri = URI("https://#{PHAB_HOST}/api/user.search")
    params = {
      'api.token': api_key
    }

    params['after'] = after if after && after != 'null'
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri).body
  end

  def raw_transactions(after)
    uri = URI("https://#{PHAB_HOST}/api/transaction.search")
    params = {
      'api.token': api_key,
      'objectType': 'TASK',
      'limit': 1_000_000_000
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

  def parse_transactions
    comments = []
    after = 'null'

    until after.nil?
      raw = raw_transactions(after)
      parsed = JSON.parse(raw)
      after = parsed['result']['cursor']['after']
      comments << build_comments(parsed['result']['data'])
    end
    comments.flatten
  end

  def build_users(json)
    json.map do |user|
      User.new(user)
    end
  end

  def build_comments(json)
    json.map do |transaction|
      Comment.new(transaction) if transaction['type'] == 'comment'
    end.compact
  end
end
