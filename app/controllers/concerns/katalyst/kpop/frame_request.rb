# frozen_string_literal: true

# Kpop Frame Requests use a different layout than Turbo Frame requests.
#
# The layout used is <tt>kpop/frame.html.erb</tt>. If there's a need to customize this layout, an application can
# supply its own (such as <tt>app/views/layouts/kpop/frame.html.erb</tt>) which will be used instead.
#
# This module is automatically included in <tt>ActionController::Base</tt>.
module Katalyst
  module Kpop
    module FrameRequest
      extend ActiveSupport::Concern

      class_methods do
        # Example:
        #  require_kpop only: %i[new edit] { url_for(resource) }
        def require_kpop(**constraints, &fallback_location)
          define_method(:kpop_fallback_location, fallback_location) if fallback_location

          before_action :require_kpop, **constraints
        end
      end

      included do
        layout -> { turbo_frame_layout }
      end

      private

      def kpop_frame_request?
        turbo_frame_request_id == "kpop"
      end

      def require_kpop
        redirect_back(fallback_location: kpop_fallback_location, status: :see_other) unless kpop_frame_request?
      end

      def turbo_frame_layout
        if kpop_frame_request?
          "kpop/frame"
        elsif turbo_frame_request?
          "turbo_rails/frame"
        end
      end
    end
  end
end
