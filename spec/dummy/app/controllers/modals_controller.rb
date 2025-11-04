# frozen_string_literal: true

class ModalsController < ApplicationController
  before_action :delay_request
  expects_kpop { root_path }

  def show; end

  def update
    case params[:next]
    when "close"
      resume_or_redirect_back_or_to(root_path, status: :see_other)
    when "error"
      render :show, locals: { name: "error", error: true }, status: :unprocessable_content
    when "page"
      redirect_to(test_path, status: :see_other)
    when "modal"
      redirect_to(modal_path(name: params.fetch(:name, "update")), status: :see_other)
    when "stream"
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("dialog h2", "Hello stream update!") }
      end
    else
      raise NotImplementedError
    end
  end

  private

  def delay_request
    sleep(params[:duration].to_f.seconds) if params[:duration].present?
  end
end
