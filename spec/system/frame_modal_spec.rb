# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Frame modal" do
  before do
    visit root_path

    # Open modal
    click_link("Frame")

    # Wait for modal to render
    find("[data-kpop--frame-open-value='true']")
  end

  it "opens successfully" do
    # Modal shows
    within(".kpop-modal") do |kpop|
      expect(kpop).to have_content("Frame modal")
    end

    # URL changed
    expect(page).to have_current_path(modal_path)
  end

  it "supports navigation closing" do
    # Racy test, give Turbo a second here
    sleep 0.1

    # Clicking the back button closes the modal
    page.go_back

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-modal")

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports navigation re-opening" do
    # Racy test, give Turbo a second here
    sleep 0.1

    # Clicking the back button closes the modal
    page.go_back

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-modal")

    # Clicking forward re-opens the modal
    page.go_forward

    expect(page).to have_current_path(modal_path)
    within(".kpop-modal") do |kpop|
      expect(kpop).to have_content("Frame modal")
    end
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
    # Racy test, give Turbo a second here
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

    # Clicking the back button to go back to the root
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

    expect(page).to have_current_path(modal_path)
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

  it "supports navigation re-opening after submit" do
    # Fill in the form
    within(".kpop-modal") do |_kpop|
      select "home", from: "Next"
      click_button "Save"
    end

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-modal")

    sleep 0.1

    # Clicking forward re-opens the modal
    page.go_forward

    expect(page).to have_current_path(modal_path)
    within(".kpop-modal") do |kpop|
      expect(kpop).to have_content("Frame modal")
    end
  end

  it "supports rendering a new modal via form submission" do
    # Fill in the form
    within(".kpop-modal") do |_kpop|
      select "stream", from: "Next"
      click_button "Save"
    end

    expect(page).to have_current_path(root_path)
    expect(page).to have_css(".kpop-title", text: "Stream modal")

    # Clicking the back button to go back to the root path
    page.go_back

    expect(page).to have_current_path(root_path)

    # Click the back button again to show no extra history was added
    page.go_back

    expect(page).to have_current_path(nil)
  end
end
