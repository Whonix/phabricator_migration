# frozen_string_literal: true

class Issue
  attr_reader :title, :description, :id, :status, :impact, :phid, :author_phid

  def initialize(issue_data)
    @id = issue_data['id']
    @phid = issue_data['phid']
    @title = issue_data['title']
    @description = issue_data['description']
    @status = issue_data['status']
    @impact = issue_data['impact']
    @author_phid = issue_data['author_phid']
  end
end
