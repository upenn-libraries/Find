# frozen_string_literal: true

# renders the circulation options for physical holdings
class CirculationComponent < ViewComponent::Base
  attr_accessor :form

  DEFAULT_PICKUP = 'VanPeltLib'
  DEFAULT_STUDENT_PICKUP = 'VPLOCKER'

  def initialize(user_group:, form:)
    @user_group = user_group
    @form = form
  end

  def default_pickup_location
    return DEFAULT_STUDENT_PICKUP if @user_group.include? 'Student'

    DEFAULT_PICKUP
  end

  def user_is_facex?
    @user_group == 'Faculty Express'
  end
end
