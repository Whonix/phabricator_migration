# Description
A simple Ruby program for migrating the Phabricator issues to Discourse topics.

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

`$ ruby ./phabricator_migrate.rb`
