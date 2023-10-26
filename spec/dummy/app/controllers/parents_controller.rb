# frozen_string_literal: true

class ParentsController < ApplicationController
  before_action :set_parent

  def show; end

  private

  def set_parent
    @parent = Parent.first_or_create!(name: "Parent")
  end
end
