# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  def test; end

  def redirect
    redirect_to modal_path, status: :see_other
  end
end
