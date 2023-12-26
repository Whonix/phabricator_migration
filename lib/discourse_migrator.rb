class DiscourseMigrator
  attr_reader :formatted_import_data, :logfile_path

  def initialize(formatted_import_data, logfile_path)
    @formatted_import_data = formatted_import_data
    @logfile_path = logfile_path
  end

  def migrate_data
    @formatted_import_data.map do |topic|
      issue_id = topic['issue_id']
      results[issue_id] = {
        phabricator_issue_link: "https://phabricator.whonix.org/T#{topic['issue_id']}"
      }
      response = post_topic(topic)
      if response.success?
        results[issue_id]['discourse_topic_link'] = response.body.topic_url
        results[issue_id]['topic_migration_success'] = true
        topic.comments.each { |c| post_comment(c) } unless comments.empty?
        # TODO: write the results to the logfile location (results.to_json)
      elsif response.failed?
        results[issue_id]['topic_migration_success'] = false
        results[issue_id]['error_output'] = response.err_output
        # TODO: write the results to the logfile location (results.to_json)
        raise "Topic did not successfully migrate. Please inspect error output #{response.err_output}"
      else
        # TODO: write the results to the logfile location (results.to_json)
        raise 'shit is fucked stop this process and fix it'
      end
    end
  end

  def post_topic(topic)
    puts topic
    # TODO: build http post request
    # post title
    # post body
    # add tags
    # log response
    puts 'DO THANGS'
  end

  def post_comment(comment)
    # TODO: post the comment if it isnt in the hash as a sucessfully posted comment
    # add results to log hash
    # raise error and exit if failure
  end
end
