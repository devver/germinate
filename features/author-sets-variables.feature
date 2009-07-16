Feature: author sets variables

  As an author
  I want to set named values in my article
  So that I can re-use them in processes, etc.

  Scenario: setting a new variable
    Given an article with the contents:
    """
    # :TEXT:
    # This is some text
    # :SET: FOO, 123
    """
    When I run the command "germ list --variables --debug" on the article
    Then the output should be as follows:
    """
    FOO                  123
    """
    When I run the command "germ set MAGIC_WORD xyzzy --debug" on the article
    Then the article contents should be:
    """
    # :TEXT:
    # This is some text
    # :SET: FOO, 123
    # :SET: MAGIC_WORD, "xyzzy"
    """
    And the article backup contents should be:
    """
    # :TEXT:
    # This is some text
    # :SET: FOO, 123
    """
    When I run the command "germ list --variables --debug" on the article
    Then the output should be as follows:
    """
    FOO                 123
    MAGIC_WORD          xyzzy
    """

  Scenario: changing an existing variable
    Given an article with the contents:
    """
    # :PUBLISHER: env, shell, { command: 'echo %f > /dev/null; echo $FOO' }
    # :TEXT:
    # This is some text
    # :SET: FOO, 123
    """
    When I run the command "germ list --variables --debug" on the article
    Then the output should be as follows:
    """
    FOO                  123
    """
    When I run the command "germ publish env --debug" on the article
    Then the output should be as follows:
    """
    123
    """
    When I run the command "germ set FOO 456 --debug" on the article
    Then the article contents should be:
    """
    # :PUBLISHER: env, shell, { command: 'echo %f > /dev/null; echo $FOO' }
    # :TEXT:
    # This is some text
    # :SET: FOO, 456
    """
    And the article backup contents should be:
    """
    # :PUBLISHER: env, shell, { command: 'echo $FOO' }
    # :TEXT:
    # This is some text
    # :SET: FOO, 123
    """
    When I run the command "germ list --variables --debug" on the article
    Then the output should be as follows:
    """
    FOO                 456
    """
    When I run the command "germ publish env --debug" on the article
    Then the output should be as follows:
    """
    456
    """
