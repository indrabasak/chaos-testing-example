@chaos-test
Feature: Chaos Testing
  As a user
  I want to test the resiliency of my example application by injecting chaos.

  Scenario Outline: test resiliency by injecting chaos to all lambdas in a region
    Given localstack setup is up and running for testing lambdas chaos in a region
    And request to /v1/health gets a response code of 200
    When I inject lambda outage by region fault
    Then resend a GET request to /v1/health and I should get a response code of 200



