Feature: author publishes article

  As an author
  I want to publish my article as a blog post
  So that the world can see it

  Scenario: using a shell publisher
    Given an article with the contents:
    """
    # :PUBLISHER: source, shell, { select: '$SOURCE', command: "quoter %f" }
    # :BRACKET_CODE: "<pre>", "</pre>"
    # :TEXT:
    This is the text
    # :SAMPLE:
    def hello
      # ...
    end
    """
    When I run the command "germ publish source --debug " on the article
    Then the output should be as follows:
    """
    > # :PUBLISHER: source, shell, { select: '$SOURCE', command: "quoter %f" }
    > # :BRACKET_CODE: "<pre>", "</pre>"
    > # :TEXT:
    > This is the text
    > # :SAMPLE:
    > def hello
    >   # ...
    > end
    """
