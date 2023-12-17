# frozen_string_literal: true

require 'test_helper'

class UserTest < Minitest::Test
  def setup
    user_data = JSON.parse(File.read('./test/data/user.json'))
    @id = user_data['id']
    @phid = user_data['phid']
    @username = user_data['fields']['username']
    @user = User.new(user_data)
  end

  def test_it_has_an_id
    assert_equal @user.id, @id
  end

  def test_it_has_a_phid
    assert_equal @user.phid, @phid
  end

  def test_it_has_a_username
    assert_equal @user.username, @username
  end
end
