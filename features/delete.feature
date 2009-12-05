Feature: Delete Gems
  In order to remove my botched release 
  As a rubygem developer
  I want to delete gems from Gemcutter
  
@wip
  Scenario: User deletes a gem
    Given I am signed up and confirmed as "email@person.com/password"
    And I Have a gem "RGem" with version "1.2.2"
    And I have a gem "RGem" with version "1.2.3"
    And I have an api key for "email@person.com/password"
    And I've already pushed the gem "RGem-1.2.2.gem" with my api key
    And I've already pushed the gem "RGem-1.2.3.gem" with my api key
    When I delete the gem "RGem" version "1.2.3" with my api key
    And I go to my gems page
    Then I should not see "RGem"
    And I visit the gem page for "RGem"
    Then I should not see "1.2.3"

  Scenario: User deletes the last version of a gem
    Given I am signed up and confirmed as "old@owner.com/password"
    And I have a gem "RGem" with version "1.2.3"
    And I have an api key for "old@owner.com/password"
    And I've already pushed the gem "RGem-1.2.3.gem" with my api key
    When I delete the gem "RGem" version "1.2.3" with my api key
    And I go to my gems page
    Then I should not see "RGem"
    And I visit the gem page for "RGem"
    Then I should not see "1.2.3"
    And I should see "Not available for download"
    
    When I am signed up and confirmed as "new@owner.com/password"
    And I have a gem "RGem" with version "0.1.0"
    And I have an api key for "new@owner.com/password"
    When I push the gem "RGem-0.1.0.gem" with my api key
    And I visit the gem page for "RGem"
    Then I should see "RGem"
    And I should see "0.1.0"
    And I should see "new@owner.com"
    And I should not see "old@owner.com"
    
  Scenario: User who is not owner attempts to delete a gem
    Given I am signed up and confirmed as "non@owner.org/password"
    And a user exists with an email of "the@owner.org"
    And I have an api key for "non@owner.org/password"
    And a rubygem exists with a name of "RGem"
    And a version exists for the "RGem" rubygem with a number of "1.2.3"
    And the "RGem" rubygem is owned by "the@owner.org"
    When I delete the gem "RGem" version "1.2.3" with my api key
    Then I should see "You do not have permission to yank this gem."
    