# frozen_string_literal: true

class ModalsController < ApplicationController
  before_action :delay_request

  def show
    if request.headers["Turbo-Frame"] == "kpop"
      render "modals/frame", layout: "kpop"
    else
      render "home/index", layout: "application", locals: { kpop: "modals/content" }
    end
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
    when "error"
      @error = true
      render status: :unprocessable_entity
    when "frame"
      render turbo_stream: turbo_stream.kpop.redirect_to(new_parent_child_path, target: "kpop")
    when "content"
      render turbo_stream: turbo_stream.kpop.redirect_to(new_parent_child_path)
    else
      render turbo_stream: turbo_stream.kpop.open(template: "modals/stream")
    end
  end

  private

  def redirect_forwards
    respond_to do |format|
      format.html do
        redirect_to test_path, status: :see_other
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.kpop.redirect_to(test_path)
      end
    end
  end

  def close_modal
    respond_to do |format|
      format.html do
        redirect_to root_path
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.kpop.dismiss
      end
    end
  end

  def delay_request
    sleep(params[:duration].to_f.seconds) if params[:duration].present?
  end
end
