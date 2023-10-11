# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kpop::FrameComponent do
  subject(:component) { described_class.new }

  before do
    render_inline(component)
  end

  it "renders a frame" do
    expect(page).to have_css("turbo-frame#kpop")
  end
end
