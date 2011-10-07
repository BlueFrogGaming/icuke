Feature: Starting a new project
  As a developer,
  I want to install iCuke
  so I can use it.

  Scenario: Starting a new project using bundler
    Given I am in a sandbox directory
    And I copy "$CURRENT_REPO/app" to "." recursively
    And I have a file named "Gemfile" containing
      """
      source "http://rubygems.org"
      gem "iCuke", :git => "$CURRENT_REPO", :ref => "$CURRENT_REF"
      gem "rake"
      """
    And I run "gem install bundle"
    And I run "bundle install --path=./path"
    And I run "bundle exec icuke ."
    When I run "bundle exec cucumber"
    Then everything should be hoopy
