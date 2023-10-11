# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Persistent modal" do
  before do
    visit root_path
  end

  context "when opening from URL" do
    it "supports navigation closing" do
      # Click on performance tile
      click_link("Persistent")

      # Modal shows
      within("#kpop") do |kpop|
        expect(kpop).to have_content("Persistent modal")
      end

      # URL changed
      expect(page).to have_current_path(persistent_modal_path)

      # Clicking the back button closes the modal
      page.go_back

      expect(page).to have_current_path(root_path)

      # Clicking the back button again to reach the end of the history stack
      page.go_back

      expect(page).to have_current_path(nil)
    end

    it "supports internal links", pending: "history support" do
      # Click on performance tile
      click_link("Persistent")

      # Modal shows
      within("#kpop") do |kpop|
        expect(kpop).to have_content("Persistent modal")
      end

      # URL changed
      expect(page).to have_current_path(persistent_modal_path)

      # Clicking a link within the modal opens in the root page
      within("#kpop") do
        click_link("Home")
      end

      expect(page).to have_current_path(root_path)

      # Clicking the back button returns to the modal
      page.go_back

      expect(page).to have_current_path(persistent_modal_path)
    end

    it "supports internal forms", pending: "history support" do
      # Click on performance tile
      click_link("Persistent")

      # Modal shows
      within("#kpop") do |kpop|
        expect(kpop).to have_content("Persistent modal")
      end

      # URL changed
      expect(page).to have_current_path(persistent_modal_path)

      # Clicking a link within the modal opens in the root page
      within("#kpop") do
        click_link("Submit")
      end

      expect(page).to have_current_path(root_path)

      # Clicking the back button returns to the modal
      page.go_back

      expect(page).to have_current_path(persistent_modal_path)
    end
  end
end
