# frozen_string_literal: true

class ChildrenController < ParentsController
  def new
    if kpop_frame_request?
      render locals: { child: @parent.children.build }
    else
      render :show, locals: { child: @parent.children.build }
    end
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

  def child_params
    params.require(:child).permit(:name)
  end
end
