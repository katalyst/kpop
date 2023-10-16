# frozen_string_literal: true

class ModalsController < ApplicationController
  layout "kpop"

  def anonymous
    redirect_to root_path, status: :see_other unless request.headers["Turbo-Frame"] == "kpop"
  end

  def persistent
    unless request.headers["Turbo-Frame"] == "kpop"
      @dismiss = root_path
      render "home/index", layout: "application", locals: { kpop: "modals/persistent" }
    end
  end

  def update
    case params[:next]
    when "home"
      close_modal
    when "test"
      redirect_forwards
    when "anonymous"
      render turbo_stream: helpers.kpop_redirect_to(anonymous_modal_path, target: "kpop")
    when "persistent"
      render turbo_stream: helpers.kpop_redirect_to(persistent_modal_path, target: "kpop")
    else
      @error = true
      render status: :unprocessable_entity
    end
  end

  private

  def redirect_forwards
    respond_to do |format|
      format.html do
        redirect_to test_path, status: :see_other
      end
      format.turbo_stream do
        render turbo_stream: helpers.kpop_redirect_to(test_path)
      end
    end
  end

  def close_modal
    respond_to do |format|
      format.html do
        redirect_to root_path
      end
      format.turbo_stream do
        render turbo_stream: helpers.kpop_dismiss
      end
    end
  end
end
