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
    When I delete the gem "RGem-1.2.3.gem" with my api key
    And I go to my gems page
    Then I should not see "RGem"
    And I visit the gem page for "RGem"
    Then I should not see "1.2.3"

  Scenario: User deletes the last version of a gem
    Given I am signed up and confirmed as "email@person.com/password"
    And I have a gem "RGem" with version "1.2.3"
    And I have an api key for "email@person.com/password"
    And I've already pushed the gem "RGem-1.2.3.gem" with my api key
    When I delete the gem "RGem-1.2.3.gem" with my api key
    And I go to my gems page
    Then I should not see "RGem"
    And I visit the gem page for "RGem"
    Then I should not see "1.2.3"
    And I should see "Not available for download"
    
  