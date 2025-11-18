# frozen_string_literal: true

module Kpop
  class ModalComponent < ViewComponent::Base
    attr_reader :title

    def initialize(title:, modal_class:)
      super()

      @title       = title
      @modal_class = modal_class
    end

    def label
      sanitize(title)
    end

    def modal_class
      @modal_class.to_s.dasherize
    end

    def inspect
      "#<#{self.class.name} title: #{title.inspect}>"
    end

    private

    def path
      request.fullpath
    end
  end
end
