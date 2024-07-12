# frozen_string_literal: true

require "rspec/rails"

module Katalyst
  module Kpop
    module Matchers
      class Base < RSpec::Rails::Matchers::BaseMatcher
        attr_reader :matched

        def matches?(actual)
          @matched = super
          @matched.present?
        end
      end
    end
  end
end
