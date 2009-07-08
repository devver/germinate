Feature: author formats article

  As an author
  I want to format my articles
  So that they can be published

  Scenario Outline: format article
    Given the article "<input_file>"
    When I run the format command on the article
    Then the output should look like "<output_file>"

  Scenarios:
    | input_file      | output_file      |
    | article1.rb     | article1.html    |
    | article2.rb     | article2.html    |


  Scenario: format text followed by code
    Given an article with the contents:
      """
      # :TEXT:
      # This is my article
    
      this is my code 
      """
    When I run the format command on the article
    Then the output should be as follows:
      """
      This is my article
  
      this is my code
      """

  Scenario: format code with bracketing
    Given an article with the contents:
      """
      # :BRACKET_CODE: "<pre>", "</pre>"
      # :TEXT:
      # This is my article
    
      this is my code 
      """
    When I run the format command on the article
    Then the output should be as follows:
      """
      This is my article
  
      <pre>
      this is my code
      </pre>
      """

  Scenario: override default bracketing
    Given an article with the contents:
      """
      # :BRACKET_CODE: "<pre>", "</pre>"
      # :TEXT: SECTION1
      # This is my article
    
      # :SAMPLE: SECTION1, { brackets: [ '[code]', '[/code]' ] }
      this is my code 
      """
    When I run the format command on the article
    Then the output should be as follows:
      """
      This is my article
  
      [code]
      this is my code
      [/code]
      """
