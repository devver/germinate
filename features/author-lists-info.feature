Feature: author lists information

  As an author
  I want to list the various components of my article
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
    When I run the command "germ list --sections" on the article
    Then the output should be as follows:
      """
      SECTION1
      A
      """
    When I run the command "germ list --samples" on the article
    Then the output should be as follows:
      """
      SECTION1
      SECTION2
      X
      """
    When I run the command "germ list --processes" on the article
    Then the output should be as follows:
      """
      frob
      munge
      """
