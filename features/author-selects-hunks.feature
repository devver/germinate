Feature: author experiments with selectors

  As an author
  I want to test the behavior of various selectors
  So that I know what to use in my article

  Scenario: list stuff
    Given an article with the contents:
      """
      # :TEXT: A
      # Section A

      # :SAMPLE: X
      X 1
      X 2
      X 3
      X 4

      # :PROCESS: quote, "quoter %f"
      """
    When I run the command "germ select '@X:2..3|quote'" on the article
    Then the output should be as follows:
      """
      > X 2
      > X 3
      """
