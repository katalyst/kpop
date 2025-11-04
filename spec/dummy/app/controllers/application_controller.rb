# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout -> { hotwire_native_app? ? "hotwire" : super() }
end
