# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'erb'

# This class posts Discourse topics by parsing a JSON file created by the Formatter
class DiscourseMigrator
  attr_reader :formatted_import_data

  def initialize(formatted_import_data)
    @formatted_import_data = formatted_import_data
    @uri = URI('https://forums.whonix.org/posts.json')
  end

  def read_logs
    JSON.parse(File.read('./logs/migration.log'))
  end

  def migrate_data
    @formatted_import_data.each do |issue|
      @logs = read_logs
      duplicate = handle_duplicates(issue['phid'])
      next if duplicate

      req = build_post_request(issue)
      res = post_topic(req)
      handle_response(res, issue)
    end
  end

  def handle_duplicates(phid)
    if @logs.keys.include?(phid) && @logs[phid] == 'completed'
      true
    else
      false
    end
  end

  def post_topic(req)
    Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: true) do |http|
      http.request(req)
    end
  end

  def handle_response(res, issue)
    case res
    when Net::HTTPSuccess
      @logs[issue['phid']] = 'completed'
      File.write('./logs/migration.log', @logs.to_json)
    else
      puts res.body
      puts issue['phid']
      puts issue['title']
      sleep 10 if res.code == '429'
    end
  end

  def build_post_request(issue)
    raw = build_topic(issue)
    req = Net::HTTP::Post.new(@uri)
    req['Api-Key'] = ENV['DISCOURSE_KEY']
    req['Api-Username'] = 'phabricator-migrator'
    req['Content-Type'] = 'application/json'
    req.set_form_data(form_data(issue, raw))
    req
  end

  def form_data(issue, raw)
    {
      'title': handle_title(issue['title']),
      'category': 25,
      'raw': raw,
      'tags[]': map_tags(issue['status'])
    }
  end

  def handle_title(title)
    return title unless title.size < 15

    "#{title} (TITLE LENGTH EXTENDED)"
  end

  def map_tags(status)
    tag_map = {
      'resolved' => 'status_closed_issue_implemented',
      'invalid' => 'status_closed_invalid',
      'wontfix' => 'status_closed_invalid',
      'open' => 'status_open_issue_todo',
      'testbuild' => 'status_open_issue_rebuild_test_required',
      'duplicate' => 'status_closed_invalid'
    }
    tag_map[status]
  end

  def build_topic(issue)
    topic_template = File.read('./templates/topic.txt.erb')
    topic_erb = ERB.new(topic_template).result(binding)
    comments_erb = build_comments(issue['comments']) unless issue['comments'].empty?
    if comments_erb
      topic_erb + comments_erb
    else
      topic_erb
    end
  end

  def build_comments(comments)
    comment_template = File.read('./templates/comment.txt.erb')
    comments_erb = ''
    comments.each do |comment|
      comments_erb += ERB.new(comment_template).result(binding)
    end
    comments_erb
  end
end
