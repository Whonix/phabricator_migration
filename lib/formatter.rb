# frozen_string_literal: true

# This class formats issues, comments, and users in to a usable file for posting to Discourse
class Formatter
  attr_reader :issues, :comments, :users, :linked_export_data, :formatted_import_data

  def initialize(issues, comments, users)
    @issues = issues
    @comments = comments.sort_by(&:date_created)
    @users = users
    @linked_export_data = {}
  end

  def write_file(path)
    json = linked_export_data.to_json
    File.write(path, json)
  end

  def link_export_data
    add_issues
    add_comments
    drop_keys
    linked_export_data
  end

  def add_issues
    issues.each do |issue|
      @linked_export_data[issue.phid] =
        { id: issue.id, phid: issue.phid, title: issue.title, status: issue.status, priority: issue.priority,
          author: lookup_author(issue.author_phid), description: issue.description, comments: [] }
    end
  end

  def add_comments
    comments.each do |comment|
      @linked_export_data[comment.task_phid][:comments] << {
        author: lookup_author(comment.author_phid),
        date_created: comment.date_created,
        date_modified: comment.date_modified,
        content: comment.content
      }
    end
  end

  def drop_keys
    @linked_export_data = linked_export_data.map do |_phid, issue_data|
      issue_data
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
