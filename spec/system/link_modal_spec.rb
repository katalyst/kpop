# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Modal opened from link" do
  include KpopMatchers

  def modal_link
    page.find("a[href]", text: "Modal")
  end

  def open_modal
    visit root_path
    page.driver.wait_for_network_idle

    # Open modal
    click_link("Modal")

    # Wait for modal to render
    modal
  end

  def modal_closed_successfully
    expect(page).to have_no_modal
    expect(frame).to have_src(nil)
    expect(page.active_element).to eq(modal_link)
  end

  it "opens successfully" do
    open_modal

    # Modal shows
    within(modal) do |kpop|
      expect(kpop).to have_content("Hello modal!")
    end

    # Frame URL changed
    expect(frame).to have_src(modal_path)

    # Active element changed
    expect(page.active_element).to eq(close_button)
  end

  it "supports escape closing" do
    open_modal

    # Pressing escape closes the modal
    send_keys(:escape)

    modal_closed_successfully

    # Clicking the back button to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports re-opening" do
    open_modal

    # Clicking the back button closes the modal
    page.send_keys(:escape)

    modal_closed_successfully

    # Clicking on the active element re-opens the modal
    page.active_element.click

    within(modal) do |kpop|
      expect(kpop).to have_content("Hello modal!")
    end

    expect(frame).to have_src(modal_path)
  end

  it "supports button closing" do
    open_modal

    # Clicking the close button closes the modal
    close_button.click

    modal_closed_successfully

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports scrim closing" do
    open_modal

    # Clicking the scrim closes the modal
    page.driver.click(10, 10)

    modal_closed_successfully

    # Clicking the back button again to reach the end of the history stack
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
    expect(frame).to have_src(nil)

    # Clicking the back button to go back to the root
    page.go_back

    expect(page).to have_current_path(root_path)
    expect(page).to have_no_modal
    expect(frame).to have_src(nil)

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports close via form submission" do
    open_modal

    # Fill in the form
    within(modal) do
      click_button "Close"
    end

    modal_closed_successfully

    # Click the back button to show no extra history was added
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports redirect via form submission" do
    open_modal

    # Fill in the form
    within(modal) do
      click_button "Page"
    end

    expect(page).to have_current_path(test_path)
    expect(page).to have_no_modal
    expect(frame).to have_src(nil)

    # Click the back button to return to root
    page.go_back

    expect(page).to have_current_path(root_path)
    expect(page).to have_no_modal
    expect(frame).to have_src(nil)

    # Click the back button again to show no extra history was added
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports form errors on form submission" do
    open_modal

    # Fill in the form
    within(modal) do
      click_button "Error"
    end

    expect(page).to have_modal("Hello error modal!")
    expect(frame).to have_src(modal_path(next: "error"))

    within(modal) do |kpop|
      expect(kpop).to have_content("Modal has errors")
      click_button "Close"
    end

    modal_closed_successfully

    # Click the back button to show no extra history was added
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports re-opening after submit" do
    open_modal

    # Fill in the form
    within(modal) do
      click_button "Close"
    end

    modal_closed_successfully

    # Clicking re-opens the modal
    page.active_element.click

    expect(frame).to have_src(modal_path)
    within(modal) do |kpop|
      expect(kpop).to have_content("Hello modal!")
    end
  end

  it "supports rendering a new modal on form submission" do
    open_modal

    # Fill in the form
    within(modal) do
      click_button "Modal"
    end

    expect(page).to have_current_path(root_path)
    expect(page).to have_modal("Hello update modal!")
    expect(page.active_element).to eq(close_button)

    # Pressing escape closes the modal
    page.send_keys(:escape)

    modal_closed_successfully

    # Click the back button to show no history was added
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "debounces double open requests" do
    visit root_path
    page.driver.wait_for_network_idle

    # Open two modals
    click_link("Delay 0.5")
    sleep 0.1
    click_link("Delay 0.6")
    sleep 0.1

    # Wait for modal to render
    modal

    expect(frame).to have_src(modal_path(duration: "0.6"))

    within(modal) do
      click_button("Close")
    end

    expect(page).to have_current_path(root_path)
    expect(page).to have_no_modal
    expect(frame).to have_src(nil)
  end
end
