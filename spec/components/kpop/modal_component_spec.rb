# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kpop::ModalComponent do
  subject(:component) { described_class.new(title: "Test") }

  before do
    render_inline(component)
  end

  it "renders a modal" do
    expect(page).to have_css(".kpop-modal")
  end

  it "renders title" do
    expect(page).to have_css(".kpop-title", text: "Test")
  end

  it "renders close" do
    expect(page).to have_css(".kpop-close")
  end

  context "when captive" do
    subject(:component) { described_class.new(title: "Test", captive: true) }

    it "does not render close" do
      expect(page).not_to have_css(".kpop-close")
    end
  end

  context "with css class" do
    subject(:component) { described_class.new(title: "Test", class: "extra") }

    it "renders both classes" do
      expect(page).to have_css(".kpop-modal.extra")
    end
  end

  context "with stimulus controller" do
    subject(:component) { described_class.new(title: "Test", data: { controller: "extra" }) }

    it "renders both controllers" do
      expect(page).to have_css("[data-controller='kpop--modal extra']")
    end
  end
end
