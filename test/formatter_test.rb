# frozen_string_literal: true

require 'test_helper'

class FormatterTest < Minitest::Test
  def setup
    VCR.use_cassette('formatter_test/setup') do
      parser = PhabricatorParser.new(PHAB_KEY)
      issues = parser.parse_issues
      users = parser.parse_users
      comments = parser.parse_transactions
      @formatter = Formatter.new(issues, comments, users)
    end
  end

  def test_it_has_phabricator_attributes
    assert_instance_of Issue, @formatter.issues.sample
    assert_instance_of Comment, @formatter.comments.sample
    assert_instance_of User, @formatter.users.sample
  end

  def test_it_formats_data
    formatted_data = @formatter.format_data
    task = formatted_data['PHID-TASK-hjxtpmlmudn7crk2qmnv']

    assert_equal '553', task[:id]
    assert_equal 'Emergency Crash Script to Protect Host FDE', task[:title]
    assert_equal 'resolved', task[:status]
    assert_equal 'HulaHoop', task[:author]
    assert_equal "One interesting feature I remember from Truecrypt was the ability to crash the system (using a user defined custom key) in an emergency shutdown to protect encrypted host data from seizure.\n\nOn Linux the way this would work is to enable the kernel feature for it and have a script execute the sysrq-trigger on demand - mapped to a key of the user's choice.\n\nhttps://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/s2-kdump-configuration-testing.html\n\nThen type the following commands at a shell prompt:\n\necho 1 > /proc/sys/kernel/sysrq\necho c > /proc/sysrq-trigger",
                 task[:description]

    assert_equal 'HulaHoop', task[:comments].first[:author]
    assert_equal 'Tested this and I found it causes the VM to freeze and hang. Far from the emergency solution I was looking for.',
                 task[:comments].first[:content]
    assert_equal 1_472_773_970, task[:comments].first[:date_created]
    assert_equal 'marmarek', task[:comments].last[:author]
    assert_equal "On Qubes it results in kernel message: `sysrq: SysRq : This sysrq operation is disabled.`\nDefault value of `/proc/sys/kernel/sysrq` on Qubes dom0 is 16. Changing to `1` does not work either:\n```\n[1363616.422789] sysrq: SysRq : Power Off\n[1363616.423456] xenbus: xenbus_dev_shutdown: backend/console/1069/0: Initialising != Connected, skipping\n[1363621.427069] xenbus: xenbus_dev_shutdown: backend/vbd/1069/51760 timeout closing device\n[1363626.430065] xenbus: xenbus_dev_shutdown: backend/vbd/1069/51744 timeout closing device\n[1363631.434062] xenbus: xenbus_dev_shutdown: backend/vbd/1069/51728 timeout closing device\n[1363636.437593] xenbus: xenbus_dev_shutdown: backend/vbd/1069/51712 timeout closing device\n[1363636.437595] xenbus: xenbus_dev_shutdown: backend/console/1068/0: Initialising != Connected, skipping\n[1363641.441056] xenbus: xenbus_dev_shutdown: backend/vbd/1068/51760 timeout closing device\n[1363646.443064] xenbus: xenbus_dev_shutdown: backend/vbd/1068/51744 timeout closing device\n[1363651.446038] xenbus: xenbus_dev_shutdown: backend/vbd/1068/51728 timeout closing device\n[1363656.447016] xenbus: xenbus_dev_shutdown: backend/vbd/1068/51712 timeout closing device\n[1363656.447016] xenbus: xenbus_dev_shutdown: backend/console/1067/0: Initialising != Connected, skipping\n[1363661.448050] xenbus: xenbus_dev_shutdown: backend/vbd/1067/51760 timeout closing device\n[1363666.451077] xenbus: xenbus_dev_shutdown: backend/vbd/1067/51744 timeout closing device\n[1363671.454069] xenbus: xenbus_dev_shutdown: backend/vbd/1067/51728 timeout closing device\n[1363676.457060] xenbus: xenbus_dev_shutdown: backend/vbd/1067/51712 timeout closing device\n[1363676.457118] xenbus: xenbus_dev_shutdown: backend/console/711/0: Initialising != Connected, skipping\n[1363681.460065] xenbus: xenbus_dev_shutdown: backend/vbd/711/51760 timeout closing device\n```\nAnd finally shutdown after timing out for every VM - 20s per VM. Not good, at least.\nSysrq-c makes dom0 frozen for some time (5s?) and then reboots. Also after changing sysctl setting.",
                 task[:comments].last[:content]

    assert_equal 1_474_659_837, task[:comments].last[:date_created]
  end

  def test_it_writes_a_json_file
    path = './test/data/formatted_file.json'
    File.delete(path) if File.exist?(path)

    @formatter.write_file(path)
    written_json = JSON.parse(File.read(path))
    assert_equal @formatter.formatted_data, written_json
  end
end
