# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Nested resource" do
  before do
    visit parent_path

    # Open modal
    click_on("New child")

    # Wait for modal to render
    find("[data-kpop--frame-open-value='true']")
  end

  it "opens successfully" do
    # Modal shows
    within(".kpop-modal") do |kpop|
      expect(kpop).to have_content("New child")
    end

    # URL changed
    expect(page).to have_current_path(new_parent_child_path)
  end

  it "supports navigation closing" do
    # Racy test, give Turbo a second here
    sleep 0.1

    # Clicking the back button closes the modal
    page.go_back

    expect(page).to have_current_path(parent_path)
    expect(page).to have_no_css(".kpop-modal")
    expect(page).to have_no_css("#scrim[data-scrim-open-value='true']")
  end

  it "supports navigation re-opening" do
    # Racy test, give Turbo a second here
    sleep 0.1

    # Clicking the back button closes the modal
    page.go_back

    expect(page).to have_current_path(parent_path)
    expect(page).to have_no_css(".kpop-modal")

    # Clicking forward re-opens the modal
    page.go_forward

    expect(page).to have_current_path(new_parent_child_path)
    within(".kpop-modal") do |kpop|
      expect(kpop).to have_content("New child")
    end
  end

  it "supports form saving" do
    fill_in("Name", with: "Child")
    click_on("Create")

    expect(page).to have_current_path(parent_path)
    expect(page).to have_no_css(".kpop-modal")
    expect(page).to have_css("li", text: "Child")

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end

  it "supports form errors with abort" do
    click_on("Create")

    expect(page).to have_current_path(new_parent_child_path)
    within(".kpop-modal") do |kpop|
      expect(kpop).to have_content("Name can't be blank")
    end

    # Clicking the back button to dismiss the form
    page.go_back

    expect(page).to have_current_path(parent_path)
  end

  it "supports form errors with submit" do
    click_on("Create")

    expect(page).to have_current_path(new_parent_child_path)
    within(".kpop-modal") do |kpop|
      expect(kpop).to have_content("can't be blank")
    end

    fill_in("Name", with: "Child")
    click_on("Create")

    expect(page).to have_current_path(parent_path)

    # Clicking the back button again to reach the end of the history stack
    page.go_back

    expect(page).to have_current_path(nil)
  end
end
