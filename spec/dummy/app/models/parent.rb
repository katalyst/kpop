# frozen_string_literal: true

class Parent < ApplicationRecord
  has_many :children, dependent: :destroy

  validates :name, presence: true
end
