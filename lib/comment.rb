# frozen_string_literal: true

# This class creates an object from a parsed Phabricator comment
class Comment
  attr_reader :task_phid, :author_phid, :phid, :date_created, :date_modified, :content

  def initialize(comment_data)
    @phid = comment_data['phid']
    @task_phid = comment_data['objectPHID']
    @author_phid = comment_data['authorPHID']
    @date_created = comment_data['dateCreated']
    @date_modified = comment_data['dateModified']
    @content = get_content(comment_data['comments'])
  end

  def get_content(comments)
    valid_comments = comments.select do |comment|
      comment['removed'] == false
    end

    if valid_comments.empty?
      'NO COMMENT DATA'
    else
      valid_comments.first['content']['raw']
    end
  end
end
