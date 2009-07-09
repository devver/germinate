Feature: author formats article

  As an author
  I want to format my articles
  So that they can be published

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

  Scenario: insert a named section
    Given an article with the contents:
      """
      # :BRACKET_CODE: "<pre>", "</pre>"
    
      # :SAMPLE: sample1
      code sample 1

      # :SAMPLE: sample2
      code sample 2

      # :TEXT:
      # Here is example 2:
      # :INSERT: @sample2
      #
      # And here is example 1:
      # :INSERT: @sample1
      """
    When I run the format command on the article
    Then the output should be as follows:
      """
      Here is example 2:
      <pre>
      code sample 2
      </pre>

      And here is example 1:
      <pre>
      code sample 1
      </pre>
      """

  Scenario Outline: more formatting examples
    Given the article "<input_file>"
    When I run the format command on the article
    Then the output should look like "<output_file>"

  Scenarios:
    | input_file        | output_file        |
    | hello.rb          | hello.txt          |
    | wrapping.rb       | wrapping.txt       |
    | sample_offsets.rb | sample_offsets.txt |


