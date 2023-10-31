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
    expect(page).not_to have_css("#scrim[data-scrim-open-value='true']")

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

  it "supports rendering a new stream on form submission" do
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

  it "supports rendering a new frame on form submission" do
    # Fill in the form
    within(".kpop-modal") do |_kpop|
      select "frame", from: "Next"
      click_button "Save"
    end

    expect(page).to have_current_path(new_parent_child_path)
    expect(page).to have_css(".kpop-title", text: "New child")

    sleep 0.1

    # Clicking the back button to go back to the root path
    # Note: this happens because we use "replace" for turbo redirect_to
    page.go_back

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-title")
  end

  it "supports rendering a new page on form submission" do
    # Fill in the form
    within(".kpop-modal") do |_kpop|
      select "content", from: "Next"
      click_button "Save"
    end

    expect(page).to have_current_path(new_parent_child_path)
    expect(page).to have_css(".kpop-title", text: "New child")

    sleep 0.1

    # Clicking the back button to go back to the modal path
    # Note: this happens because we use "replace" for turbo redirect_to
    page.go_back

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_css(".kpop-title")
  end

  it "debounces double open requests" do
    page.go_back

    # Open two modals
    click_link("Delay 0.5")
    sleep 0.1
    click_link("Delay 0.6")
    sleep 0.1

    expect(page).to have_current_path(modal_path(duration: "0.6"))

    # Wait for modal to render
    find("[data-kpop--frame-open-value='true']")
    expect(page).to have_css(".kpop-title", text: "Frame modal")

    page.go_back

    expect(page).to have_current_path(root_path)
    sleep 1 # wait for animations to settle (0.5 + 0.2)
    expect(page).not_to have_css("[data-kpop--frame-open-value='true']")
  end
end
