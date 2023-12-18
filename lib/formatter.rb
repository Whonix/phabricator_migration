# frozen_string_literal: true

# This class formats issues, comments, and users in to a usable file for posting to Discourse
class Formatter
  attr_reader :issues, :comments, :users, :formatted_data

  def initialize(issues, comments, users)
    @issues = issues
    @comments = comments.sort_by(&:date_created)
    @users = users
    @formatted_data = {}
  end

  def write_file(path)
    json = formatted_data.to_json
    File.write(path, json)
  end

  def format_data
    add_issues
    add_comments
    formatted_data
  end

  def add_issues
    issues.each do |issue|
      @formatted_data[issue.phid] =
        { id: issue.id, title: issue.title, status: issue.status, priority: issue.priority,
          author: lookup_author(issue.author_phid), description: issue.description, comments: [] }
    end
  end

  def add_comments
    comments.each do |comment|
      @formatted_data[comment.task_phid][:comments] << {
        author: lookup_author(comment.author_phid),
        date_created: comment.date_created,
        date_modified: comment.date_modified,
        content: comment.content
      }
    end
  end

  def lookup_author(phid)
    author = users.select do |user|
      user.phid == phid
    end

    if author.empty?
      'Deleted Author'
    else
      author.first.username
    end
  end
end
