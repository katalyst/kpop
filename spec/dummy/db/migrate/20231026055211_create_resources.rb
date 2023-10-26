# frozen_string_literal: true

class CreateResources < ActiveRecord::Migration[7.1]
  def change
    create_table :parents do |t|
      t.string :name
    end

    create_table :children do |t|
      t.references :parent
      t.string :name
    end
  end
end
