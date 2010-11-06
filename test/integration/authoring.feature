Feature: Authoring content

  @separate-environment
  Scenario: Author a Textile post
    Given I author a post
    And I set the post content type to "textile"
    And I set the post title to "Simple Textile Post"
    And I set the post filename to "simple-textile-post.html.textile"
    And I set the post content to:
      """
      p. Here is a simple Textile post, even including a quote: 
      _"It was the best of times, it was the worst of times."_
      """
    And I save the post
    When I compile my site
    Then the result should be successful
