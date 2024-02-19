# Description
A Ruby program for migrating the Phabricator issues to Discourse topics.

## Requirements
- Installed version of Ruby 3
- A Phabricator API key
- A Discourse API key with sufficient permissions to make a bunch of topics

## How it works

1. call the phabricator API to get all the issues
2. call the phabricator API to get all the users
3. call the phabricator API to get all the transactions (comments, assignments, etc)
4. format the data in to a large JSON file
5. post it to Discourse via the Discourse API

## Usage

1. Create a file `.env` with the following content
```
PHAB_KEY=<Phabricator Conduit API key>
DISCOURSE_KEY=<Discourse API key>
PHAB_HOST='phabricator.whonix.org'
```

2. Ensure that Discourse has an appropriate rate limit for post requests. For us, 1000 a minute is probably ample.

3. `$ ruby ./phabricator_export.rb` which outputs a JSON file `./discourse_migration_data.json`

4. `$ ruby ./discourse_import.rb`

5. Tada!

### Tests

Testing is done with Ruby's built in Minitest framework.

To run them:

`$ rake`
