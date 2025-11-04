# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Content modal" do
  include KpopMatchers

  def open_modal
    visit modal_path

    # Wait for modal to render
    modal
  end

  def modal_closed_successfully
    expect(page).to have_current_path(root_path)
    expect(page).to have_no_modal
    expect(frame).to have_src(nil)
  end

  it "opens successfully" do
    open_modal

    expect(page).to have_current_path(root_path) # opening modal as a normal visit redirects to root url
    expect(page).to have_content("Hello world!") # root page is rendered in the background

    # Modal shows
    expect(page).to have_modal("Hello modal!")
  end

  it "does not add history" do
    open_modal

    # Clicking the back button leaves the site
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports button closing" do
    open_modal

    # Clicking the close button closes the modal
    close_button.click

    modal_closed_successfully

    # Clicking the back button leaves the site
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports scrim closing" do
    open_modal

    # Clicking the scrim closes the modal
    page.driver.click(10, 10)

    modal_closed_successfully

    # Clicking the back button leaves the site
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports forward navigation" do
    open_modal

    # Clicking a link to go forward
    within(modal) do
      click_link("Page")
    end

    expect(page).to have_current_path(test_path)
    expect(page).to have_no_modal

    # Clicking the back button returns to the root page without the modal
    page.go_back

    modal_closed_successfully

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports close via form submission" do
    open_modal

    # Fill in the form
    within(modal) do |_kpop|
      click_button "Close"
    end

    modal_closed_successfully

    # Clicking the back button leaves the site
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports redirect via form submission" do
    open_modal

    # Fill in the form
    within(modal) do |_kpop|
      click_button "Page"
    end

    expect(page).to have_current_path(test_path)
    expect(page).to have_no_modal

    # Clicking the back button returns to the root page without the modal
    page.go_back

    modal_closed_successfully

    # Clicking the back button again leaves the site
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports form errors on form submission" do
    open_modal

    # Fill in the form
    within(modal) do |_kpop|
      click_button "Error"
    end

    expect(page).to have_current_path(root_path)
    expect(page).to have_modal

    within(modal) do |kpop|
      expect(kpop).to have_content("Modal has errors")
      click_button "Close"
    end

    modal_closed_successfully

    # Clicking the back button leaves the site
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports rendering a new modal via form submission" do
    open_modal

    # Fill in the form
    within(modal) do |_kpop|
      click_button "Modal"
    end

    expect(page).to have_current_path(root_path)
    expect(page).to have_modal("Hello update modal!")

    # Pressing escape closes the new modal
    page.send_keys(:escape)

    modal_closed_successfully

    # Clicking the back button again leaves the site
    page.go_back

    expect(page).to have_current_path(nil)
  end
end
