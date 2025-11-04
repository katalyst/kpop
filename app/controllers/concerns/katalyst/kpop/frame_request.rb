# frozen_string_literal: true

# Kpop Frame Requests use a different layout than Turbo Frame requests.
#
# The layout used is <tt>kpop/frame.html.erb</tt>. If there's a need to
# customise this layout, an application can supply its own
# (<tt>app/views/layouts/kpop/frame.html.erb</tt>)
# which will be used instead.
#
# This module is automatically included in <tt>ActionController::Base</tt>.
module Katalyst
  module Kpop
    module FrameRequest
      extend ActiveSupport::Concern

      class_methods do
        # Sets the expectation that these actions will be wrapped in a modal.
        # Adds custom layouts, rendering, and redirect behaviours to make this
        # happen.
        #
        # If a get request is received for one of these paths which does not
        # already support modals (i.e. hotwire native, kpop frame requests)
        # then the user will be redirected back, or to the provided fallback
        # location with a flash set so that modal shows when that page renders.
        #
        # Add the routes to your kpop config in application.js so that the
        # extra flash request is not required for normal visits.
        #
        # Example:
        #  expects_kpop(only: %i[new create]) { url_for(action: :index) }
        def expects_kpop(**constraints, &fallback_location)
          define_method(:kpop_fallback_location, fallback_location) if fallback_location

          before_action :expects_kpop, **constraints
        end
      end

      included do
        add_flash_types :modal_location

        layout -> { turbo_frame_layout }
      end

      def kpop_available?
        request.headers["Kpop-Available"] == "true"
      end

      def kpop_frame_request?
        turbo_frame_request_id == "kpop"
      end

      def kpop_stream_request?
        request.headers["Kpop-Stream-Request"] == "true"
      end

      private

      def expects_kpop
        if kpop_available? && request.headers["Accept"].include?("text/vnd.turbo-stream.html")
          request.headers["Kpop-Stream-Request"] = "true"
        end

        return if !request.get? || turbo_frame_request? || kpop_stream_request? || hotwire_native_app?

        redirect_back_or_to(kpop_fallback_location, status: :see_other, modal_location: request.fullpath)
      end

      def render(...)
        if kpop_stream_request?
          response_body = super

          if rendered_format == Mime[:html]
            response_body      = render_to_string(turbo_stream: turbo_stream.action(:kpop_open, "kpop", response_body))
            self.content_type  = Mime[:turbo_stream]
            self.response_body = response_body
          end

          response_body
        else
          super
        end
      end

      def turbo_frame_layout
        if kpop_frame_request?
          "kpop/frame"
        elsif kpop_stream_request?
          "kpop/stream"
        elsif turbo_frame_request?
          "turbo_rails/frame"
        end
      end

      # Add support for closing kpop modals
      #
      # @overload Turbo::Native::Navigation#turbo_native_action_or_redirect
      def turbo_native_action_or_redirect(url, action, redirect_type, options = {})
        if kpop_stream_request?
          redirect_to send("turbo_#{action}_historical_location_url", notice: options[:notice])
        else
          super
        end
      end
    end
  end
end
