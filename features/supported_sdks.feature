Feature: Supported SDKs
  As a developer,
  in order to test applications that need to run on older devices,
  iCuke should be able to boot applications under different simulator SDKs.

  Scenario: SDK 3.2
    Given "app/Universal.xcodeproj" is loaded in the iphone simulator with SDK 3.2
    Then I should see "Show Test Modal"

  Scenario: SDK 4.2
    Given "app/Universal.xcodeproj" is loaded in the iphone simulator with SDK 4.2
    Then I should see "Show Test Modal"
