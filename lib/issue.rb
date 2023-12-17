# frozen_string_literal: true

# This class creates an object from a parsed Phabricator issue
class Issue
  attr_reader :title, :description, :id, :status, :priority, :phid, :author_phid

  def initialize(issue_data)
    @id = issue_data['id']
    @phid = issue_data['phid']
    @title = issue_data['title']
    @description = issue_data['description']
    @status = issue_data['status']
    @priority = issue_data['priority']
    @author_phid = issue_data['authorPHID']
  end
end
