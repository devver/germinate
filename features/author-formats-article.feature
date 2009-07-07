Feature: author formats article

  As an author
  I want to format my articles
  So that they can be published

  Scenario Outline: format article
    Given the article "<input_file>"
    When I run the format command on the article
    Then the output should look like "<output_file>"

  Scenarios:
    | input_file   | output_file   |
    | article1.rb  | article1.html |
    | article2.rb  | article2.html |
