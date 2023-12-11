# frozen_string_literal: true

class User
  attr_reader :username, :phid, :id

  def initialize(user_data)
    @id = user_data['id']
    @phid = user_data['phid']
    @username = user_data['fields']['username']
  end
end
