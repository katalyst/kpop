# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScrimComponent do
  subject(:component) { described_class.new }

  before do
    render_inline(component)
  end

  it "renders a scrim" do
    expect(page).to have_css("div#scrim")
  end
end
