# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Stream modal" do
  before do
    visit root_path

    # Open modal
    click_button("Stream")

    # Wait for modal to render
    find("[data-kpop--frame-open-value='true'] .kpop-modal")
  end

  it "opens successfully" do
    # Modal shows
    within(".kpop-modal") do |kpop|
      expect(kpop).to have_content("Stream modal")
    end

    # URL did not change
    expect(page).to have_current_path(root_path)
  end

  it "supports navigation closing" do
    # Clicking the back button closes the modal
    page.go_back

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-modal")

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports button closing" do
    # Clicking the close button closes the modal
    find(".kpop-close").click

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-modal")

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports scrim closing" do
    sleep 0.1

    # Clicking the scrim closes the modal
    find_by_id("scrim").trigger("click")

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-modal")

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports forward navigation" do
    # Clicking a link to go forward
    click_link("Test")

    expect(page).to have_current_path(test_path)
    expect(page).not_to have_css(".kpop-modal")

    # Clicking the back button to go back home
    page.go_back

    expect(page).to have_current_path(root_path)

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports close via form submission" do
    # Fill in the form
    within(".kpop-modal") do |_kpop|
      select "home", from: "Next"
      click_button "Save"
    end

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-modal")

    # Click the back button to show no extra history was added
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports redirect via form submission" do
    # Fill in the form
    within(".kpop-modal") do |_kpop|
      select "test", from: "Next"
      click_button "Save"
    end

    expect(page).to have_current_path(test_path)
    expect(page).not_to have_css(".kpop-modal")

    # Click the back button to return to root
    page.go_back

    expect(page).to have_current_path(root_path)

    # Click the back button again to show no extra history was added
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports form errors on form submission" do
    # Fill in the form
    within(".kpop-modal") do |_kpop|
      select "error", from: "Next"
      click_button "Save"
    end

    expect(page).to have_current_path(root_path)
    expect(page).to have_css(".kpop-modal")

    within(".kpop-modal") do |kpop|
      expect(kpop).to have_content("Form is invalid")
      select "home", from: "Next"
      click_button "Save"
    end

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-modal")

    # Click the back button to show no extra history was added
    page.go_back

    expect(page).to have_current_path(nil)
  end
end
