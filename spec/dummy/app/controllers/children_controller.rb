# frozen_string_literal: true

class ChildrenController < ApplicationController
  before_action :set_parent

  layout "kpop"

  def new
    render locals: { child: @parent.children.build }
  end

  def create
    child = @parent.children.build(child_params)
    if child.save
      render locals: { children: @parent.children }
    else
      render :errors, locals: { child: }
    end
  end

  private

  def set_parent
    @parent = Parent.first
  end

  def child_params
    params.require(:child).permit(:name)
  end
end
