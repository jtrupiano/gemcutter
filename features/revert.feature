Feature: Revert gem versions
  In order to remove a crappy gem
  As a rubygem developer
  I want to remove the last version of the gem

@wip
  Scenario: User reverts a gem with two versions
    Given I am signed up and confirmed as "email@person.com/password"
    And I have a gem "RGem" with version "1.2.2"
    And I have a gem "RGem" with version "1.2.3"
    And I have an api key for "email@person.com/password"
    And I've already pushed the gem "RGem-1.2.2.gem" with my api key
    And I've already pushed the gem "RGem-1.2.3.gem" with my api key
    When I revert the gem "RGem" with my api key
    And I visit the gem page for "RGem"
    Then I should not see "1.2.3"
    And I should see "1.2.2"

  Scenario: User reverts a gem with one version
    Given I am signed up and confirmed as "email@person.com/password"
    And I have a gem "RGem" with version "1.2.3"
    And I have an api key for "email@person.com/password"
    And I've already pushed the gem "RGem-1.2.3.gem" with my api key
    When I attempt to revert the gem "RGem" with my api key
    And I visit the gem page for "RGem"
    And I should see "1.2.3"