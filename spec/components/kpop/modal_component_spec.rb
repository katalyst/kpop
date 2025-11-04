# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kpop::ModalComponent do
  subject(:component) { described_class.new(title: "Test", modal_class: "test-modal") }

  before do
    render_inline(component)
  end

  it "renders a modal" do
    expect(page).to have_css("dialog")
  end

  it "renders label" do
    expect(page).to have_css("dialog[aria-label='Test']")
  end

  it "renders title" do
    expect(page).to have_css("header h2", text: "Test")
  end

  it "renders close" do
    expect(page).to have_css("header button[aria-label='close']")
  end

  it "renders class" do
    expect(page).to have_css("dialog.test-modal")
  end
end
