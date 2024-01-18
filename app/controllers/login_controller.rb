# frozen_string_literal: true

# handles requests from user login entrypoint
class LoginController < ApplicationController
  def index
    if Rails.env.production?
      head :not_found
    else
      render :index
    end
  end
end
