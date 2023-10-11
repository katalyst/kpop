# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Anonymous modal" do
  before do
    visit root_path
  end

  context "when opening from URL" do
    it "supports navigation closing", pending: "history support" do
      # Click on performance tile
      click_link("Anonymous")

      # Modal shows
      within("#kpop") do |kpop|
        expect(kpop).to have_content("Anonymous modal")
      end

      # URL did not change
      expect(page).to have_current_path(root_path)

      # Clicking the back button closes the modal
      page.go_back

      expect(page).to have_current_path(root_path)

      # Clicking the back button again to reach the end of the history stack
      page.go_back

      expect(page).to have_current_path(nil)
    end
  end
end
