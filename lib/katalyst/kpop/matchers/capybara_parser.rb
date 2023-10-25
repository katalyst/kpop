# frozen_string_literal: true

require "katalyst/kpop/matchers/base"

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class CapybaraParser < Base
        def match(_, actual)
          @html = Nokogiri::HTML5.parse(actual.body)
          Capybara::Node::Simple.new(@html)
        end
      end
    end
  end
end
