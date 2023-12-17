require 'test_helper'

class CommentTest < Minitest::Test
  def setup
    transaction_data = JSON.parse(File.read('./test/data/transaction.json'))
    @phid = transaction_data['phid']
    @date_created = transaction_data['dateCreated']
    @date_modified = transaction_data['dateModified']
    @content = transaction_data['comments'].first['content']['raw']
    @author_phid = transaction_data['authorPHID']
    @task_phid = transaction_data['objectPHID']
    @comment = Comment.new(transaction_data)
  end

  def test_it_has_a_phid
    assert_equal @comment.phid, @phid
  end

  def test_it_has_a_date_created
    assert_equal @comment.date_created, @date_created
  end

  def test_it_has_a_date_modified
    assert_equal @comment.date_modified, @date_modified
  end

  def test_it_has_content
    assert_equal @comment.content, @content
  end

  def test_it_has_an_author_phid
    assert_equal @comment.author_phid, @author_phid
  end

  def test_it_has_a_task_phid
    assert_equal @comment.task_phid, @task_phid
  end
end
