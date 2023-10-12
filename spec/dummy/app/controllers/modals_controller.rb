# frozen_string_literal: true

class ModalsController < ApplicationController
  def anonymous
    respond_to do |format|
      format.html do
        return redirect_to root_path, status: :see_other unless request.headers["Turbo-Frame"] == "kpop"

        render layout: "kpop"
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("kpop", template: "modals/anonymous")
      end
    end
  end

  def persistent
    respond_to do |format|
      format.html do
        return redirect_to root_path, status: :see_other unless request.headers["Turbo-Frame"] == "kpop"

        render layout: "kpop"
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("kpop", template: "modals/persistent")
      end
    end
  end

  def update
    respond_to do |format|
      format.html do
        return redirect_to root_path
      end
      format.turbo_stream do
        render turbo_stream: helpers.kpop_redirect_to(root_path)
      end
    end
  end
end
