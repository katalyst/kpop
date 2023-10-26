# frozen_string_literal: true

class Child < ApplicationRecord
  belongs_to :parent

  validates :name, presence: true
end
