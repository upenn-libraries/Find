# frozen_string_literal: true

# renders form for new request
class RequestComponent < ViewComponent::Base
  def initialize(mms_id:, holding_id:, holding_labels:, item_labels:, user_group:)
    @mms_id = mms_id
    @holding_id = holding_id
    @holding_labels = holding_labels
    @item_labels = item_labels
    @user_group = user_group
  end
end

# more logic here, like passing in a user and setting a default pickup location
# different pickup locations can be more components that render conditionally based on user info
# we can test component logic without committing to full page appearance
# making this a component will allow us to render it in different ways, passing info into the component to style etc
