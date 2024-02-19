require 'uri'
require 'net/http'
require 'json'
require 'erb'

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
      if @logs.keys.include?(issue['phid']) && @logs[issue['phid']] == 'completed'
        puts "Skipping #{issue['phid']}" && break
      end
      req = build_post_request(issue)
      res = post_topic(req)
      debugger
      handle_response(res, issue['phid'])
      debugger
    end
  end

  def post_topic(req)
    Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: true) do |http|
      http.request(req)
    end
  end

  def handle_response(res, phid)
    case res
    when Net::HTTPSuccess
      @logs[phid] = 'completed'
      File.write('./logs/migration.log', @logs.to_json)
    else
      res.value
      raise "Issue #{phid} failed to post"
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
      'title': issue['title'],
      'category': 25,
      'raw': raw,
      'tags': [map_tags(issue['status'])]
    }
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
