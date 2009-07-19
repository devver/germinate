Feature: author views information

  As an author
  I want to view the components of my article
  So that I can diagnose errors in output

  Scenario: list stuff
    Given an article with the contents:
      """
      # :TEXT:
      # Anonymous section 1
    
      anonymous code 1
      # :END:

      anonymous code 2

      # :TEXT: A
      # Section A

      # :SAMPLE: X
      code sample X

      # :PROCESS: frob, "aaa"
      # :PROCESS: munge, "bbb"
      """
    When I run the command "germ show --section=SECTION1" on the article
    Then the output should be as follows:
      """
      # Anonymous section 1
      
      Insertion[@SECTION1]
      """
    When I run the command "germ show --section=A" on the article
    Then the output should be as follows:
      """
      # Section A

      """
    When I run the command "germ show --sample=X" on the article
    Then the output should be as follows:
      """
      code sample X

      """
    When I run the command "germ show --process=munge" on the article
    Then the output should be as follows:
      """
      bbb
      """
