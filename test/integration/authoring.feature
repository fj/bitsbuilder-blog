@separate-environment
Feature: Authoring content

  Scenario: Author a Textile post
    Given I have a post "x.html.textile" with metadata:
      | field      | value                              |
      | kind       | article                            |
      | title      | "Unit Testing One: Textile Markup" |
      | stub       | textile-unit-test                  |
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

  Scenario: Author a Markdown post
    Given I have a post "y.html.markdown" with metadata:
      | field      | value                               |
      | kind       | article                             |
      | title      | "Unit Testing Two: Markdown Markup" |
      | stub       | markdown-unit-test                  |
      | created at | 2010-10-01 12:34                    |
      | entity id  | 1                                   |
    And I have a post "y.html.markdown" with content:
      """
      Here is a simple Markdown post, followed by a block quote:

      > _"It was the best of times, it was the worst of times."_
      >
      > __This text__ is marked as strong.
      """
    When I compile my site
    Then the result should be successful
    And I should see the files I added

  Scenario: Prevent authoring two posts with identical identifiers
    Given I have a post "a.html.textile" with metadata:
      | field     | value   |
      | kind      | article |
      | stub      | x       |
      | entity id | 1       |
    And I have a post "b.html.textile" with metadata:
      | field     | value   |
      | kind      | article |
      | stub      | y       |
      | entity id | 1       |
    And I have a post "a.html.textile" with content:
      """
      p. This is Textile post one.
      """
    And I have a post "b.html.textile" with content:
      """
      p. This is Textile post two.
      """
    When I compile my site
    Then the result should be unsuccessful because "some articles have non-unique or nil values for entity_id"
