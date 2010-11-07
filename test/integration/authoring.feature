Feature: Authoring content

  @separate-environment
  Scenario: Author a Textile post
    Given I have a post "x.html.textile" with metadata:
      | field      | value                              |
      | kind       | article                            |
      | title      | "Unit Testing One: Textile Markup" |
      | stub       | one                                |
      | created at | 2010-10-01 12:34                   |
      | entity id  | 1                                  |
    And I have a post "x.html.textile" with content:
      """
      p. Here is a simple Textile post, even including a quote: 
      _"It was the best of times, it was the worst of times."_
      """
    When I compile my site
    Then the result should be successful
    And I should see the files I added
