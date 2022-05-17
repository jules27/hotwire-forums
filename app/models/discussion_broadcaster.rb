class DiscussionBroadcaster
  attr_reader :discussion

  def initialize(discussion)
    @discussion = discussion
  end

  def broadcast!
    replace_header
    replace_new_post_form if discussion.saved_change_to_closed?
    move_categories if discussion.saved_change_to_category_id?
  end

  private

  def replace_header
    # Broadcast to anyone who is subscribed on the discussion page
    discussion.broadcast_replace(partial: "discussions/header", locals: { discussion: discussion })
  end

  # If a discussion is closed, broadcast that update
  def replace_new_post_form
    discussion.broadcast_action_to(
      discussion,
      action: :replace,
      target: "new_post_form",
      partial: "discussions/posts/form",
      locals: { post: discussion.posts.new }
    )
  end

  # If the category is changed, broadcast the change so it's
  # updated in real time for subscribers
  def move_categories
    old_category_id, new_category_id = @discussion.saved_change_to_category_id

    old_category = Category.find(old_category_id)
    new_category = Category.find(new_category_id)

    move_discussion_to_category(old_category, new_category)
    update_categories(old_category, new_category)
  end

  # Remove it from the old category list / insert to new list
  def move_discussion_to_category(old_category, new_category)
    discussion.broadcast_remove_to(old_category)
    discussion.broadcast_prepend_to(new_category)
  end

  # Update categories by replacing them. This updates the counters in the sidebar.
  def update_categories(old_category, new_category)
    old_category.reload.broadcast_replace_to("categories")
    new_category.reload.broadcast_replace_to("categories")
  end
end
