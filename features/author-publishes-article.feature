Feature: author publishes article

  As an author
  I want to publish my article as a blog post
  So that the world can see it

  Scenario: using a shell publisher
    Given an article with the contents:
    """
    # :PUBLISHER: source, shell, { command: "quoter %f", select: '$SOURCE' }
    # :BRACKET_CODE: "<pre>", "</pre>"
    # :TEXT:
    # This is the text
    # :SAMPLE:
    def hello
      # ...
    end
    """
    When I run the command "germ publish source --debug " on the article
    Then the output should be as follows:
    """
    > # :PUBLISHER: source, shell, { command: "quoter %f", select: '$SOURCE' }
    > # :BRACKET_CODE: "<pre>", "</pre>"
    > # :TEXT:
    > # This is the text
    > # :SAMPLE:
    > def hello
    >   # ...
    > end
    """

  Scenario: using a shell publisher with a pipeline
    Given an article with the contents:
    """
    # :PROCESS: quote, "quoter %f"
    # :PUBLISHER: source, shell, { command: "quoter %f", pipeline: quote, select: '$SOURCE' }
    # :BRACKET_CODE: "<pre>", "</pre>"
    # :TEXT:
    # This is the text
    # :SAMPLE:
    def hello
      # ...
    end
    """
    When I run the command "germ publish source --debug " on the article
    Then the output should be as follows:
    """
    > > # :PROCESS: quote, "quoter %f"
    > > # :PUBLISHER: source, shell, { command: "quoter %f", pipeline: quote, select: '$SOURCE' }
    > > # :BRACKET_CODE: "<pre>", "</pre>"
    > > # :TEXT:
    > > # This is the text
    > > # :SAMPLE:
    > > def hello
    > >   # ...
    > > end
    """
