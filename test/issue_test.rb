# frozen_string_literal: true

require 'test_helper'

class IssueTest < Minitest::Test
  def setup
    issue_data = JSON.parse(File.read('./test/data/issue.json'))
    @id = issue_data['id']
    @phid = issue_data['phid']
    @title = issue_data['title']
    @description = issue_data['description']
    @status = issue_data['status']
    @priority = issue_data['priority']
    @author_phid = issue_data['authorPHID']
    @issue = Issue.new(issue_data)
  end

  def test_it_has_an_id
    assert_equal @issue.id, @id
  end

  def test_it_has_a_phid
    assert_equal @issue.phid, @phid
  end

  def test_it_has_a_title
    assert_equal @issue.title, @title
  end

  def test_it_has_a_description
    assert_equal @issue.description, @description
  end

  def test_it_has_a_status
    assert_equal @issue.status, @status
  end

  def test_it_has_a_priority
    assert_equal @issue.priority, @priority
  end

  def test_it_has_an_author_phid
    assert_equal @issue.author_phid, @author_phid
  end
end
